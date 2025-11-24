#!/bin/bash

# Install eksctl on Linux (including AWS CloudShell)

echo "Installing eksctl for Linux..."

# Download and install eksctl
curl --silent --location "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp

# Move to PATH
sudo mv /tmp/eksctl /usr/local/bin

# Verify installation
echo "Verifying installation..."
eksctl version

echo "eksctl installed successfully!"