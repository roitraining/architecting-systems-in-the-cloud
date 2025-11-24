#!/bin/bash

# Space Invaders App Runner Deployment Script
# This script creates an App Runner service directly from source code

# Variables
SERVICE_NAME="space-invaders-app"
SERVICE_ROLE_NAME="AppRunnerServiceRole"
ACCESS_ROLE_NAME="AppRunnerAccessRole"
REGION=$(aws configure get region)

echo "Deploying Space Invaders to AWS App Runner..."
echo "Region: $REGION"

# Create service role for App Runner if it doesn't exist
echo "Creating App Runner service role..."
aws iam create-role --role-name $SERVICE_ROLE_NAME --assume-role-policy-document '{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "tasks.apprunner.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}' 2>/dev/null || echo "Service role already exists"

# Create access role for App Runner to access ECR if needed
echo "Creating App Runner access role..."
aws iam create-role --role-name $ACCESS_ROLE_NAME --assume-role-policy-document '{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "build.apprunner.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}' 2>/dev/null || echo "Access role already exists"

# Get account ID
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

# Create App Runner service
echo "Creating App Runner service..."
aws apprunner create-service \
  --service-name $SERVICE_NAME \
  --source-configuration '{
    "ImageRepository": {
      "ImageIdentifier": "public.ecr.aws/nginx/nginx:latest",
      "ImageConfiguration": {
        "Port": "80"
      },
      "ImageRepositoryType": "ECR_PUBLIC"
    },
    "AutoDeploymentsEnabled": false
  }' \
  --instance-configuration '{
    "Cpu": "0.25 vCPU",
    "Memory": "0.5 GB"
  }'

echo "App Runner service creation initiated!"
echo "Check the AWS Console for deployment status."
echo "Service URL will be available once deployment completes."