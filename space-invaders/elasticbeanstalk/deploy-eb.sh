#!/bin/bash

# Deploy Space Invaders to Elastic Beanstalk

APP_NAME="space-invaders-app"
ENV_NAME="space-invaders-env"
PLATFORM="64bit Amazon Linux 2 v5.8.4 running Node.js 18"

echo "Deploying Space Invaders to Elastic Beanstalk..."

# Create application if it doesn't exist
aws elasticbeanstalk create-application \
  --application-name $APP_NAME \
  --description "Space Invaders demo app" 2>/dev/null || echo "Application already exists"

# Create ZIP package
cd ..
zip -r elasticbeanstalk/space-invaders-eb.zip src elasticbeanstalk/package.json elasticbeanstalk/server.js -x "*.git*" "*.DS_Store*"
cd elasticbeanstalk

# Upload to S3 (you'll need to create a bucket)
BUCKET_NAME="space-invaders-deployments-$(date +%s)"
aws s3 mb s3://$BUCKET_NAME
aws s3 cp space-invaders-eb.zip s3://$BUCKET_NAME/

# Create application version
aws elasticbeanstalk create-application-version \
  --application-name $APP_NAME \
  --version-label "v$(date +%s)" \
  --source-bundle S3Bucket=$BUCKET_NAME,S3Key=space-invaders-eb.zip

# Create environment
aws elasticbeanstalk create-environment \
  --application-name $APP_NAME \
  --environment-name $ENV_NAME \
  --solution-stack-name "$PLATFORM" \
  --version-label "v$(date +%s)"

echo "Deployment initiated! Check AWS Console for environment URL."