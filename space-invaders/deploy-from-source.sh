#!/bin/bash

# Space Invaders App Runner Deployment from Source Code
# This script creates an App Runner service from a GitHub repository

# Variables
SERVICE_NAME="space-invaders-app"
GITHUB_REPO_URL="https://github.com/YOUR_USERNAME/space-invaders"  # Replace with your repo
BRANCH="main"
REGION=$(aws configure get region)

echo "Deploying Space Invaders to AWS App Runner from source..."
echo "Region: $REGION"

# Create App Runner service from source
aws apprunner create-service \
  --service-name $SERVICE_NAME \
  --source-configuration '{
    "CodeRepository": {
      "RepositoryUrl": "'$GITHUB_REPO_URL'",
      "SourceCodeVersion": {
        "Type": "BRANCH",
        "Value": "'$BRANCH'"
      },
      "CodeConfiguration": {
        "ConfigurationSource": "CONFIGURATION_FILE"
      }
    },
    "AutoDeploymentsEnabled": false
  }' \
  --instance-configuration '{
    "Cpu": "0.25 vCPU",
    "Memory": "0.5 GB"
  }' \
  --query 'Service.ServiceUrl' \
  --output text

echo ""
echo "App Runner service created!"
echo "The service will build and deploy automatically."
echo "Check AWS Console for deployment progress and service URL."