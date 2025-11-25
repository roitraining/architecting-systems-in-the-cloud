#!/bin/bash

# User Data script for EC2 instances in Auto Scaling Group
# Installs and starts the Image Processing application

# Update system
yum update -y

# Install Python 3 and pip
yum install -y python3 python3-pip

# Install CloudWatch agent
yum install -y amazon-cloudwatch-agent

# Create application directory
mkdir -p /opt/image-processor
cd /opt/image-processor

# Download application files from S3 (will be uploaded during setup)
aws s3 cp s3://BUCKET_NAME/app.py . --region us-east-1
aws s3 cp s3://BUCKET_NAME/requirements.txt . --region us-east-1
aws s3 cp s3://BUCKET_NAME/templates/ ./templates/ --recursive --region us-east-1

# Install Python dependencies
pip3 install -r requirements.txt

# Set environment variables
export SQS_QUEUE_URL="QUEUE_URL_PLACEHOLDER"
export S3_BUCKET="BUCKET_NAME_PLACEHOLDER"
export AWS_REGION="us-east-1"

# Create systemd service
cat > /etc/systemd/system/image-processor.service << EOF
[Unit]
Description=Image Processing Autoscaling Demo
After=network.target

[Service]
Type=simple
User=ec2-user
WorkingDirectory=/opt/image-processor
Environment=SQS_QUEUE_URL=QUEUE_URL_PLACEHOLDER
Environment=S3_BUCKET=BUCKET_NAME_PLACEHOLDER
Environment=AWS_REGION=us-east-1
ExecStart=/usr/bin/python3 app.py
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# Start and enable service
systemctl daemon-reload
systemctl enable image-processor
systemctl start image-processor

# Configure CloudWatch agent
cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json << EOF
{
    "metrics": {
        "namespace": "AutoScaling/Demo",
        "metrics_collected": {
            "cpu": {
                "measurement": ["cpu_usage_idle", "cpu_usage_iowait", "cpu_usage_user", "cpu_usage_system"],
                "metrics_collection_interval": 60,
                "totalcpu": true
            },
            "disk": {
                "measurement": ["used_percent"],
                "metrics_collection_interval": 60,
                "resources": ["*"]
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

# Install nginx as reverse proxy
yum install -y nginx

# Configure nginx
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

# Remove default nginx config
rm -f /etc/nginx/conf.d/default.conf

# Start nginx
systemctl enable nginx
systemctl start nginx

# Signal that instance is ready
/opt/aws/bin/cfn-signal -e $? --stack STACK_NAME --resource AutoScalingGroup --region us-east-1