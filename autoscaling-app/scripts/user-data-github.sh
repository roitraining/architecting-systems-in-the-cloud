#!/bin/bash

# !------------------ IMPORTANT ------------------!
# THIS SCRIPT IS FOR DEMONSTRATION PURPOSES ONLY.
# THIS SCRIPT USES A HARDCODED S3 BUCKET AND QUEUE URL.
# THESE MUST BE SET BEFORE RUNNING IN A DIFFERENT ACCOUNT
# THAN THE ONE USED FOR THE DEMO SETUP.
# !------------------ IMPORTANT ------------------!

# Set S3 Bucket
export S3_BUCKET="838a-lab-bucket "

# Set SQS Queue
export SQS_QUEUE_URL="https://sqs.us-east-1.amazonaws.com/774305598097/838a-lab-queue"

# User Data script for Auto Scaling Group instances
# Downloads and installs the Image Processing app from GitHub

# Update system and install dependencies
yum update -y
yum install -y python3 python3-pip git nginx

# Clone the repository from GitHub
cd /opt
git clone https://github.com/roitraining/architecting-systems-in-the-cloud.git
cd architecting-systems-in-the-cloud/autoscaling-app/src

# Install Python dependencies
pip3 install -r requirements.txt

# Create systemd service for the application
cat > /etc/systemd/system/image-processor.service << EOF
[Unit]
Description=Image Processing Autoscaling Demo
After=network.target

[Service]
Type=simple
User=ec2-user
WorkingDirectory=/opt/architecting-systems-in-the-cloud/autoscaling-app/src
Environment=AWS_REGION=us-east-1
Environment=S3_BUCKET=your-bucket-name
ExecStart=/usr/bin/python3 app.py
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# Configure nginx as reverse proxy
cat > /etc/nginx/conf.d/app.conf << EOF
server {
    listen 80;
    server_name _;
    
    location / {
        proxy_pass http://127.0.0.1:5000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
}
EOF

# Remove default nginx configuration
rm -f /etc/nginx/conf.d/default.conf

# Start and enable services
systemctl daemon-reload
systemctl enable image-processor nginx
systemctl start image-processor nginx

# Install and configure CloudWatch agent for monitoring
yum install -y amazon-cloudwatch-agent

# Configure CloudWatch agent
cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json << EOF
{
    "metrics": {
        "namespace": "AutoScaling/ImageProcessor",
        "metrics_collected": {
            "cpu": {
                "measurement": ["cpu_usage_idle", "cpu_usage_user", "cpu_usage_system"],
                "metrics_collection_interval": 60,
                "totalcpu": true
            },
            "mem": {
                "measurement": ["mem_used_percent"],
                "metrics_collection_interval": 60
            }
        }
    }
}
EOF

# Start CloudWatch agent
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
    -a fetch-config \
    -m ec2 \
    -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json \
    -s

# Log completion
echo "Image Processing app installation completed at $(date)" >> /var/log/user-data.log