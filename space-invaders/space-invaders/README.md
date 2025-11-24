# Architecting Systems in the Cloud - Course 838A

## Space Invaders Demo Application

Simple AngularJS application for demonstrating AWS App Runner deployments.

### 2024 Updates
- Updated to Bootstrap 5.3.2
- Updated to jQuery 3.7.1  
- Updated to AngularJS 1.8.3 (Final LTS)
- Added AWS App Runner deployment support

## AWS App Runner Deployment

### Quick Deploy (Recommended)
```bash
aws apprunner create-service \
  --service-name space-invaders-demo \
  --source-configuration '{
    "ImageRepository": {
      "ImageIdentifier": "public.ecr.aws/nginx/nginx:latest",
      "ImageConfiguration": {
        "Port": "80"
      },
      "ImageRepositoryType": "ECR_PUBLIC"
    }
  }' \
  --instance-configuration '{
    "Cpu": "0.25 vCPU",
    "Memory": "0.5 GB"
  }'
```

### Files for App Runner
- `apprunner.yaml` - App Runner configuration
- `simple-deploy.sh` - One-command deployment
- `Dockerfile` - Container configuration
- `README-AppRunner.md` - Detailed deployment guide

## Docker (Local Testing)
```bash
docker build -t space-invaders:v3.0 .
docker run -p 8080:80 space-invaders:v3.0
```

## Author
Doug Rehnstrom  
ROI Training  
doug@roitraining.com