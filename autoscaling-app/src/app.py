#!/usr/bin/env python3
"""
Image Processing Autoscaling Demo
Simple Flask app that processes images to demonstrate CPU-based autoscaling
"""

import os
import time
import boto3
import json
from flask import Flask, render_template, request, jsonify, redirect, url_for
from PIL import Image, ImageFilter, ImageEnhance
import io
import base64
from datetime import datetime
import threading
import queue
import psutil

app = Flask(__name__)

# AWS Configuration
SQS_QUEUE_URL = os.environ.get('SQS_QUEUE_URL', '')
S3_BUCKET = os.environ.get('S3_BUCKET', 'autoscaling-demo-images')
AWS_REGION = os.environ.get('AWS_REGION', 'us-east-1')

# Initialize AWS clients
sqs = boto3.client('sqs', region_name=AWS_REGION)
s3 = boto3.client('s3', region_name=AWS_REGION)

# Processing queue and status
processing_queue = queue.Queue()
job_status = {}

class ImageProcessor:
    def __init__(self):
        self.is_processing = False
        
    def cpu_intensive_resize(self, image, sizes):
        """CPU-intensive image processing to trigger autoscaling"""
        results = []
        
        for size in sizes:
            # Multiple resize operations to increase CPU usage
            for _ in range(5):  # Repeat operations to increase CPU load
                resized = image.resize(size, Image.Resampling.LANCZOS)
                
                # Apply multiple filters (CPU intensive)
                enhanced = ImageEnhance.Sharpness(resized).enhance(1.5)
                enhanced = ImageEnhance.Contrast(enhanced).enhance(1.2)
                enhanced = ImageEnhance.Color(enhanced).enhance(1.1)
                
                # Apply blur and unsharp mask (very CPU intensive)
                blurred = enhanced.filter(ImageFilter.GaussianBlur(radius=2))
                final = Image.blend(enhanced, blurred, 0.3)
                
            results.append(final)
            
        return results
    
    def process_image(self, job_id, image_data, filename):
        """Process a single image with multiple CPU-intensive operations"""
        try:
            job_status[job_id] = {'status': 'processing', 'progress': 0}
            
            # Decode image
            image = Image.open(io.BytesIO(base64.b64decode(image_data)))
            
            # Define multiple sizes for processing
            sizes = [(800, 600), (400, 300), (200, 150), (100, 75)]
            
            job_status[job_id]['progress'] = 20
            
            # CPU-intensive processing
            processed_images = self.cpu_intensive_resize(image, sizes)
            
            job_status[job_id]['progress'] = 60
            
            # Additional CPU load - create thumbnails with effects
            thumbnails = []
            for img in processed_images:
                for effect in [ImageFilter.BLUR, ImageFilter.CONTOUR, ImageFilter.EDGE_ENHANCE]:
                    thumb = img.copy()
                    thumb = thumb.filter(effect)
                    thumbnails.append(thumb)
            
            job_status[job_id]['progress'] = 80
            
            # Save to S3 (simulate)
            output_buffer = io.BytesIO()
            processed_images[0].save(output_buffer, format='JPEG', quality=85)
            
            # Upload to S3
            s3_key = f"processed/{job_id}_{filename}"
            try:
                s3.put_object(
                    Bucket=S3_BUCKET,
                    Key=s3_key,
                    Body=output_buffer.getvalue(),
                    ContentType='image/jpeg'
                )
            except Exception as e:
                print(f"S3 upload error: {e}")
            
            job_status[job_id] = {
                'status': 'completed',
                'progress': 100,
                'result_url': f"https://{S3_BUCKET}.s3.{AWS_REGION}.amazonaws.com/{s3_key}",
                'completed_at': datetime.now().isoformat()
            }
            
        except Exception as e:
            job_status[job_id] = {'status': 'error', 'error': str(e)}

processor = ImageProcessor()

def worker_thread():
    """Background worker to process images"""
    while True:
        try:
            job = processing_queue.get(timeout=1)
            processor.process_image(job['job_id'], job['image_data'], job['filename'])
            processing_queue.task_done()
        except queue.Empty:
            continue
        except Exception as e:
            print(f"Worker error: {e}")

# Start background worker
threading.Thread(target=worker_thread, daemon=True).start()

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/upload', methods=['POST'])
def upload_image():
    """Handle image upload and queue for processing"""
    if 'image' not in request.files:
        return jsonify({'error': 'No image provided'}), 400
    
    file = request.files['image']
    if file.filename == '':
        return jsonify({'error': 'No file selected'}), 400
    
    # Generate job ID
    job_id = f"job_{int(time.time())}_{len(job_status)}"
    
    # Read and encode image
    image_data = base64.b64encode(file.read()).decode('utf-8')
    
    # Queue for processing
    processing_queue.put({
        'job_id': job_id,
        'image_data': image_data,
        'filename': file.filename
    })
    
    job_status[job_id] = {'status': 'queued', 'progress': 0}
    
    return jsonify({'job_id': job_id, 'status': 'queued'})

@app.route('/status/<job_id>')
def get_status(job_id):
    """Get processing status for a job"""
    return jsonify(job_status.get(job_id, {'status': 'not_found'}))

@app.route('/metrics')
def metrics():
    """System metrics for monitoring"""
    cpu_percent = psutil.cpu_percent(interval=1)
    memory = psutil.virtual_memory()
    
    return jsonify({
        'cpu_percent': cpu_percent,
        'memory_percent': memory.percent,
        'queue_size': processing_queue.qsize(),
        'active_jobs': len([j for j in job_status.values() if j.get('status') == 'processing']),
        'total_jobs': len(job_status),
        'timestamp': datetime.now().isoformat()
    })

@app.route('/load-test')
def load_test():
    """Generate artificial load for testing autoscaling"""
    def cpu_load():
        # Generate CPU load for 30 seconds
        end_time = time.time() + 30
        while time.time() < end_time:
            # CPU intensive calculation
            sum(i * i for i in range(10000))
    
    # Start CPU load in background
    threading.Thread(target=cpu_load, daemon=True).start()
    
    return jsonify({'message': 'Load test started - CPU will be high for 30 seconds'})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=False)