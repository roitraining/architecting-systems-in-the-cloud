# Elastic Beanstalk Deployment

Deploy Space Invaders to AWS Elastic Beanstalk using Node.js platform.

## Files in this directory:
- `package.json` - Node.js dependencies and configuration
- `server.js` - Express server to serve static files from ../src
- `deploy-eb.sh` - Deployment script
- `README-ElasticBeanstalk.md` - This file

## Quick Deploy

```bash
cd elasticbeanstalk
./deploy-eb.sh
```

## Manual Deploy with EB CLI

```bash
# Install EB CLI first: pip install awsebcli

# Initialize (run from elasticbeanstalk directory)
eb init space-invaders --platform node.js --region us-east-1

# Create environment and deploy
eb create space-invaders-env
eb open
```

## What it does:
1. Uses Express.js to serve static files from `../src` directory
2. Runs on Node.js 18 platform
3. Serves the Space Invaders app on port 8080 (or PORT env var)
4. No authentication required - deploys from local files