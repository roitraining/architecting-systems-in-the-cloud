# Local Deployment Guide

For students who have pulled the repo locally and want to deploy from their local files.

## Prerequisites
- AWS CLI configured
- Docker installed and running
- Appropriate AWS permissions for ECR and App Runner

## Deploy from Local Files

```bash
cd space-invaders
./deploy-local.sh
```

This script will:
1. Build Docker image from local Dockerfile
2. Create ECR repository 
3. Push image to ECR
4. Deploy to App Runner using the local image

## Simple Deploy (Public Image)

For a quick demo without building locally:

```bash
aws apprunner create-service --cli-input-json file://apprunner-config.json
```

This uses a public nginx image (good for testing the deployment process).

## Check Status

```bash
./check-status.sh
```