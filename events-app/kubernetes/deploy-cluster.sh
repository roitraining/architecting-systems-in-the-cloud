#!/bin/bash

# Create EKS cluster using eksctl

echo "Creating EKS cluster..."
echo "This will take 10-15 minutes..."

eksctl create cluster -f create-cluster.yaml

echo ""
echo "Cluster created! Verifying nodes..."
kubectl get nodes

echo ""
echo "Cluster is ready for deployment!"
echo "Deploy the events app with: kubectl apply -f ."