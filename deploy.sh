#!/bin/bash

# Deploy Space Invaders to App Runner using JSON config

echo "Deploying Space Invaders to AWS App Runner..."

aws apprunner create-service --cli-input-json file://apprunner-config.json

echo ""
echo "Deployment initiated!"
echo "Check status with: aws apprunner list-services"
echo "Get URL with: aws apprunner describe-service --service-arn [ARN]"