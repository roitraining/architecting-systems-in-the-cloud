# Image Processing Autoscaling Demo

Demonstrates AWS Auto Scaling with a CPU-intensive image processing application.

## Architecture

```
Internet → ALB → Auto Scaling Group (t3.nano instances) → Image Processing App
                      ↓
                CloudWatch Alarms → Scaling Policies
                      ↓
                CloudWatch Dashboard (Visualization)
```

## What It Does

- **Image Processing App**: Flask web application that performs CPU-intensive image operations
- **Auto Scaling**: Automatically adds/removes EC2 instances based on CPU usage
- **Monitoring**: CloudWatch dashboard shows real-time metrics and scaling events
- **Load Testing**: Built-in buttons to trigger CPU load and demonstrate scaling

## Quick Deploy

### Prerequisites
- AWS CLI configured
- Appropriate IAM permissions for EC2, Auto Scaling, CloudWatch, S3

### Deploy Everything
```bash
cd scripts
chmod +x create-autoscaling-group.sh
./create-autoscaling-group.sh
```

### Manual Steps (Educational)

**1. Create S3 bucket and upload files:**
```bash
BUCKET_NAME="autoscaling-demo-$(date +%s)"
aws s3 mb s3://$BUCKET_NAME
aws s3 cp src/ s3://$BUCKET_NAME/ --recursive
```

**2. Create Auto Scaling Group:**
```bash
aws cloudformation create-stack \
  --stack-name image-processing-autoscaling \
  --template-body file://cloudformation/autoscaling-stack.yaml \
  --parameters \
    ParameterKey=KeyPairName,ParameterValue=your-key-pair \
    ParameterKey=VpcId,ParameterValue=vpc-12345678 \
    ParameterKey=SubnetIds,ParameterValue="subnet-12345,subnet-67890" \
    ParameterKey=S3BucketName,ParameterValue=$BUCKET_NAME \
  --capabilities CAPABILITY_IAM
```

**3. Monitor scaling:**
```bash
aws autoscaling describe-auto-scaling-groups \
  --auto-scaling-group-names image-processing-asg
```

## How to Trigger Autoscaling

### Method 1: Upload Multiple Images
1. Open the application URL
2. Click "Upload 10 Images (Trigger Scaling)"
3. Watch CPU usage spike in the dashboard
4. Observe new instances launching after 2-4 minutes

### Method 2: Generate CPU Load
1. Click "Generate CPU Load" button
2. CPU will spike to ~90% for 30 seconds
3. If done repeatedly, will trigger scaling

### Method 3: Command Line Load Test
```bash
# SSH into an instance and run CPU stress
stress --cpu 2 --timeout 300s
```

## Scaling Behavior

- **Scale Out**: CPU > 70% for 2 minutes → Add 1 instance
- **Scale In**: CPU < 30% for 5 minutes → Remove 1 instance
- **Limits**: Min 1, Max 5 instances
- **Cooldown**: 5 minutes between scaling actions

## Monitoring

### CloudWatch Dashboard
- **CPU Utilization**: Shows average CPU across all instances
- **Request Count**: Application load balancer requests
- **Instance Count**: Current, desired, and in-service instances
- **Scaling Events**: Timeline of scaling activities

### Key Metrics to Watch
- `AWS/EC2/CPUUtilization`
- `AWS/AutoScaling/GroupDesiredCapacity`
- `AWS/ApplicationELB/RequestCount`

## Project Structure

```
autoscaling-app/
├── src/                          # Application source code
│   ├── app.py                   # Flask web application
│   ├── templates/index.html     # Web interface
│   └── requirements.txt         # Python dependencies
├── scripts/                     # Deployment scripts
│   ├── create-autoscaling-group.sh  # One-command deploy
│   └── user-data.sh            # EC2 initialization script
├── cloudformation/             # Infrastructure as Code
│   └── autoscaling-stack.yaml  # Complete CloudFormation template
└── README.md                   # This file
```

## Educational Value

Students learn:
- **Auto Scaling Groups**: Configuration and policies
- **CloudWatch Alarms**: CPU-based triggers
- **Load Balancers**: Distributing traffic across instances
- **Infrastructure as Code**: CloudFormation templates
- **Monitoring**: Real-time dashboards and metrics
- **Cost Optimization**: Automatic scaling based on demand

## Cleanup

```bash
# Delete CloudFormation stack
aws cloudformation delete-stack --stack-name image-processing-autoscaling

# Delete S3 bucket
aws s3 rb s3://your-bucket-name --force

# Delete key pair
aws ec2 delete-key-pair --key-name autoscaling-demo-key
```

## Troubleshooting

### Instances not scaling
- Check CloudWatch alarms are in ALARM state
- Verify scaling policies are attached
- Check instance health in target group

### Application not loading
- Check security groups allow port 80
- Verify user data script completed successfully
- Check application logs: `sudo journalctl -u image-processor`

### High costs
- Ensure instances scale down after testing
- Use t3.nano instances (included in free tier)
- Delete resources when not in use