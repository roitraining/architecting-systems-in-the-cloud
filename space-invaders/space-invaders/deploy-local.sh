#!/bin/bash

# Deploy Space Invaders from local files to App Runner
# Students run this after git pull

echo "Building and deploying Space Invaders from local files..."

# Build Docker image locally
docker build -t space-invaders:latest .

# Tag for ECR (replace with your account ID and region)
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REGION=$(aws configure get region)
ECR_URI="$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/space-invaders:latest"

echo "Tagging image: $ECR_URI"
docker tag space-invaders:latest $ECR_URI

# Create ECR repository if it doesn't exist
aws ecr create-repository --repository-name space-invaders --region $REGION 2>/dev/null || echo "Repository already exists"

# Login to ECR
aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com

# Push image
echo "Pushing image to ECR..."
docker push $ECR_URI

# Update config with ECR image
cat > apprunner-config-local.json << EOF
{
  "ServiceName": "space-invaders-demo",
  "SourceConfiguration": {
    "ImageRepository": {
      "ImageIdentifier": "$ECR_URI",
      "ImageConfiguration": {
        "Port": "80"
      },
      "ImageRepositoryType": "ECR"
    },
    "AutoDeploymentsEnabled": false
  },
  "InstanceConfiguration": {
    "Cpu": "0.25 vCPU",
    "Memory": "0.5 GB"
  }
}
EOF

# Deploy to App Runner
echo "Deploying to App Runner..."
aws apprunner create-service --cli-input-json file://apprunner-config-local.json

echo "Deployment complete! Check AWS Console for service URL."