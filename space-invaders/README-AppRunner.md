# Space Invaders - AWS App Runner Deployment

This guide shows how to deploy the Space Invaders application to AWS App Runner using simple AWS CLI commands.

## Quick Deploy (Recommended for Course)

Run this command in CloudShell or AWS CLI:

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

## Files Created

- `apprunner.yaml` - App Runner configuration file
- `simple-deploy.sh` - One-command deployment script
- `deploy-from-source.sh` - GitHub source deployment (requires repo)

## Usage

1. **Simple deployment**: Run `./simple-deploy.sh`
2. **Check status**: 
   ```bash
   aws apprunner describe-service --service-arn [SERVICE_ARN]
   ```
3. **Get URL**:
   ```bash
   aws apprunner list-services --query 'ServiceSummaryList[0].ServiceUrl'
   ```

## Clean Up

```bash
aws apprunner delete-service --service-arn [SERVICE_ARN]
```

## Notes

- Uses nginx base image from ECR Public
- Minimal 0.25 vCPU / 0.5 GB configuration
- No CI/CD pipeline required
- Perfect for AWS course demonstrations