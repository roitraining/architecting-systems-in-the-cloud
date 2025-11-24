# Architecting Systems in the Cloud - Course 838A

## Space Invaders Demo Application

This is a demo app that uses a simple Angular JS website. It can be deployed anywhere (virtual machines, App Engine, Cloud Run, Kubernetes, App Runner, etc.)

We use this application in training classes to demo things like Cloud Deployments and CI/CD pipelines.

### 2024 Updates
- Updated to Bootstrap 5.3.2
- Updated to jQuery 3.7.1  
- Updated to AngularJS 1.8.3 (Final LTS)
- Added AWS App Runner deployment support

## AWS App Runner
See the `README-AppRunner.md` file for App Runner deployment instructions.

Quick deploy:
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

## Docker
The Dockerfile is configured to copy the App into a Docker Image with Nginx installed.

To build the image:
```
docker build -t [your-docker-id]/space-invaders:v3.0 .
```
To run the image on port 8080:
```
docker run -p 8080:80 [your-docker-id]/space-invaders:v3.0
```

## App Engine
See the app.yaml file for App Engine configuration

## Kubernetes
Kubernetes Configuration files are located in the `kubernetes-configs` folder

## Author
Doug Rehnstrom  
ROI Training  
doug@roitraining.com
