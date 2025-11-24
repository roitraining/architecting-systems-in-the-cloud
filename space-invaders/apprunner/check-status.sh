#!/bin/bash

# Check App Runner service status and get URL

SERVICE_NAME="space-invaders-demo"

echo "Checking App Runner service status..."

# Get service ARN
SERVICE_ARN=$(aws apprunner list-services --query "ServiceSummaryList[?ServiceName=='$SERVICE_NAME'].ServiceArn" --output text)

if [ -z "$SERVICE_ARN" ]; then
    echo "Service not found: $SERVICE_NAME"
    exit 1
fi

echo "Service ARN: $SERVICE_ARN"

# Get service details
aws apprunner describe-service --service-arn $SERVICE_ARN --query 'Service.{Status:Status,ServiceUrl:ServiceUrl}' --output table