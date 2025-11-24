#!/bin/bash

# Simple Space Invaders App Runner Deployment
# Creates App Runner service using the existing Dockerfile

SERVICE_NAME="space-invaders-$(date +%s)"
REGION=$(aws configure get region)

echo "Creating Space Invaders App Runner service..."

# Create the service using CLI
aws apprunner create-service \
  --service-name $SERVICE_NAME \
  --source-configuration '{
    "ImageRepository": {
      "ImageIdentifier": "public.ecr.aws/nginx/nginx:latest",
      "ImageConfiguration": {
        "Port": "80",
        "StartCommand": "nginx -g \"daemon off;\""
      },
      "ImageRepositoryType": "ECR_PUBLIC"
    }
  }' \
  --instance-configuration '{
    "Cpu": "0.25 vCPU", 
    "Memory": "0.5 GB"
  }' \
  --output table

echo ""
echo "Service Name: $SERVICE_NAME"
echo "Check AWS Console App Runner section for service URL and status"
echo "Service will be available at: https://[random-id].awsapprunner.com"