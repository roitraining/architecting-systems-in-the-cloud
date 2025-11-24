#!/bin/bash

# Create App Runner connection to GitHub
echo "Creating App Runner connection to GitHub..."

# Create the connection
CONNECTION_ARN=$(aws apprunner create-connection \
  --connection-name "github-connection" \
  --provider-type GITHUB \
  --query 'Connection.ConnectionArn' \
  --output text)

echo "Connection ARN: $CONNECTION_ARN"
echo ""
echo "IMPORTANT: You need to complete the GitHub authorization!"
echo "1. Go to AWS Console > App Runner > Connections"
echo "2. Find 'github-connection' and click 'Complete handshake'"
echo "3. Authorize with GitHub"
echo ""
echo "After authorization, update apprunner-config.json:"
echo "Replace 'REPLACE_WITH_CONNECTION_ARN' with: $CONNECTION_ARN"