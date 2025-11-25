#!/bin/bash

# Create Auto Scaling Group for Image Processing Demo
# This script creates all necessary AWS resources

set -e

# Configuration
STACK_NAME="image-processing-autoscaling"
REGION="us-east-1"
KEY_PAIR_NAME="autoscaling-demo-key"
BUCKET_NAME="autoscaling-demo-$(date +%s)"

echo "Creating Image Processing Auto Scaling Group..."
echo "Stack Name: $STACK_NAME"
echo "Region: $REGION"
echo "S3 Bucket: $BUCKET_NAME"

# Create S3 bucket for application files
echo "Creating S3 bucket..."
aws s3 mb s3://$BUCKET_NAME --region $REGION

# Upload application files to S3
echo "Uploading application files..."
aws s3 cp ../src/app.py s3://$BUCKET_NAME/ --region $REGION
aws s3 cp ../src/requirements.txt s3://$BUCKET_NAME/ --region $REGION
aws s3 cp ../src/templates/ s3://$BUCKET_NAME/templates/ --recursive --region $REGION

# Create key pair if it doesn't exist
echo "Creating EC2 key pair..."
aws ec2 create-key-pair --key-name $KEY_PAIR_NAME --region $REGION --query 'KeyMaterial' --output text > ${KEY_PAIR_NAME}.pem 2>/dev/null || echo "Key pair already exists"
chmod 400 ${KEY_PAIR_NAME}.pem 2>/dev/null || true

# Get default VPC and subnets
echo "Getting VPC information..."
VPC_ID=$(aws ec2 describe-vpcs --filters "Name=is-default,Values=true" --region $REGION --query 'Vpcs[0].VpcId' --output text)
SUBNET_IDS=$(aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VPC_ID" --region $REGION --query 'Subnets[*].SubnetId' --output text | tr '\t' ',')

echo "VPC ID: $VPC_ID"
echo "Subnet IDs: $SUBNET_IDS"

# Create CloudFormation stack
echo "Creating CloudFormation stack..."
aws cloudformation create-stack \
  --stack-name $STACK_NAME \
  --template-body file://../cloudformation/autoscaling-stack.yaml \
  --parameters \
    ParameterKey=KeyPairName,ParameterValue=$KEY_PAIR_NAME \
    ParameterKey=VpcId,ParameterValue=$VPC_ID \
    ParameterKey=SubnetIds,ParameterValue="$SUBNET_IDS" \
    ParameterKey=S3BucketName,ParameterValue=$BUCKET_NAME \
  --capabilities CAPABILITY_IAM \
  --region $REGION

echo "Stack creation initiated. Waiting for completion..."
aws cloudformation wait stack-create-complete --stack-name $STACK_NAME --region $REGION

# Get stack outputs
echo "Getting stack outputs..."
LOAD_BALANCER_URL=$(aws cloudformation describe-stacks --stack-name $STACK_NAME --region $REGION --query 'Stacks[0].Outputs[?OutputKey==`LoadBalancerURL`].OutputValue' --output text)
DASHBOARD_URL=$(aws cloudformation describe-stacks --stack-name $STACK_NAME --region $REGION --query 'Stacks[0].Outputs[?OutputKey==`CloudWatchDashboardURL`].OutputValue' --output text)

echo ""
echo "✅ Auto Scaling Group created successfully!"
echo ""
echo "🌐 Application URL: $LOAD_BALANCER_URL"
echo "📊 CloudWatch Dashboard: $DASHBOARD_URL"
echo ""
echo "📋 Next Steps:"
echo "1. Wait 2-3 minutes for instances to fully initialize"
echo "2. Open the application URL in your browser"
echo "3. Click 'Upload 10 Images' to trigger autoscaling"
echo "4. Monitor the CloudWatch dashboard to see scaling in action"
echo ""
echo "🔧 To delete everything:"
echo "aws cloudformation delete-stack --stack-name $STACK_NAME --region $REGION"
echo "aws s3 rb s3://$BUCKET_NAME --force"