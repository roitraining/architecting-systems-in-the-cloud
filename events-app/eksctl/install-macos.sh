#!/bin/bash

# Install eksctl on macOS

echo "Installing eksctl for macOS..."

# Check if Homebrew is installed
if command -v brew &> /dev/null; then
    echo "Using Homebrew to install eksctl..."
    brew install eksctl
else
    echo "Homebrew not found. Installing eksctl manually..."
    
    # Download and install eksctl manually
    curl --silent --location "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
    
    # Move to PATH
    sudo mv /tmp/eksctl /usr/local/bin
fi

# Verify installation
echo "Verifying installation..."
eksctl version

echo "eksctl installed successfully!"