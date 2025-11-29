#!/bin/bash

# Space Invaders Kubernetes Deployment Script

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Space Invaders Kubernetes Deployment ===${NC}"

# Check if AWS CLI is configured
if ! aws sts get-caller-identity &> /dev/null; then
    echo -e "${RED}Error: AWS CLI not configured${NC}"
    exit 1
fi

# Get AWS account ID and region
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REGION=${AWS_REGION:-us-east-1}

echo -e "${GREEN}AWS Account ID: ${ACCOUNT_ID}${NC}"
echo -e "${GREEN}Region: ${REGION}${NC}"

# Create ECR repository if it doesn't exist
echo -e "${BLUE}Creating ECR repository...${NC}"
aws ecr describe-repositories --repository-names space-invaders --region $REGION 2>/dev/null || \
    aws ecr create-repository --repository-name space-invaders --region $REGION

# Build Docker image
echo -e "${BLUE}Building Docker image...${NC}"
cd ..
docker build -t space-invaders:latest .

# Tag image for ECR
echo -e "${BLUE}Tagging image for ECR...${NC}"
docker tag space-invaders:latest $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/space-invaders:latest

# Login to ECR
echo -e "${BLUE}Logging in to ECR...${NC}"
aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com

# Push image to ECR
echo -e "${BLUE}Pushing image to ECR...${NC}"
docker push $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/space-invaders:latest

# Update deployment YAML with account ID
echo -e "${BLUE}Updating deployment YAML...${NC}"
cd kubernetes
sed "s/ACCOUNT_ID/$ACCOUNT_ID/g" space-invaders-deployment.yaml > space-invaders-deployment-updated.yaml

# Apply Kubernetes deployment
echo -e "${BLUE}Deploying to Kubernetes...${NC}"
kubectl apply -f space-invaders-deployment-updated.yaml

# Wait for deployment
echo -e "${BLUE}Waiting for deployment to be ready...${NC}"
kubectl rollout status deployment/space-invaders

# Get LoadBalancer URL
echo -e "${BLUE}Getting LoadBalancer URL...${NC}"
echo -e "${GREEN}Waiting for LoadBalancer to be provisioned (this may take a few minutes)...${NC}"
kubectl get service space-invaders-service --watch

echo -e "${GREEN}Deployment complete!${NC}"
echo -e "${GREEN}Access your Space Invaders game at the LoadBalancer URL above${NC}"
