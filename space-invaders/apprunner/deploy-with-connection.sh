#!/bin/bash

# Deploy Space Invaders to App Runner using CONNECTION_ARN variable

if [ -z "$CONNECTION_ARN" ]; then
    echo "Error: CONNECTION_ARN environment variable not set"
    echo "Run: export CONNECTION_ARN=your-connection-arn"
    exit 1
fi

echo "Using Connection ARN: $CONNECTION_ARN"

# Create config with connection ARN
cat > apprunner-config-temp.json << EOF
{
  "ServiceName": "space-invaders-demo",
  "SourceConfiguration": {
    "CodeRepository": {
      "RepositoryUrl": "https://github.com/roitraining/architecting-systems-in-the-cloud",
      "SourceDirectory": "space-invaders",
      "SourceCodeVersion": {
        "Type": "BRANCH",
        "Value": "main"
      },
      "CodeConfiguration": {
        "ConfigurationSource": "API",
        "CodeConfigurationValues": {
          "Runtime": "NODEJS_18",
          "BuildCommand": "npm install -g http-server",
          "StartCommand": "http-server -p 8080",
          "Port": "8080"
        }
      }
    },
    "ConnectionArn": "$CONNECTION_ARN",
    "AutoDeploymentsEnabled": false
  },
  "InstanceConfiguration": {
    "Cpu": "0.25 vCPU",
    "Memory": "0.5 GB"
  }
}
EOF

# Deploy
aws apprunner create-service --cli-input-json file://apprunner-config-temp.json

# Clean up
rm apprunner-config-temp.json

echo "Deployment initiated!"