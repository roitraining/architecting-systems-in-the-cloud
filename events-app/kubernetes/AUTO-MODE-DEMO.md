# EKS Auto Mode Demo

## Overview

This demo shows the difference between traditional EKS clusters with node groups and EKS Auto Mode clusters that automatically manage compute resources.

---

## Part 1: Traditional Cluster (Without Auto Mode)

### Step 1: Create Traditional Cluster

```bash
eksctl create cluster -f create-cluster.yaml
```

This creates a cluster with a fixed node group (2 nodes, t3.medium).

### Step 2: Configure kubectl

```bash
aws eks update-kubeconfig --name events-cluster --region us-east-1
```

### Step 3: Check Initial Nodes

```bash
kubectl get nodes
```

You should see **2 nodes** running (from the node group).

### Step 4: Deploy Test Workload

```bash
kubectl apply -f inflate-deployment.yaml
```

### Step 5: Scale Up

```bash
kubectl scale deployment inflate --replicas=5
```

Watch what happens:
```bash
kubectl get pods -w
```

**Result:** Some pods may be **Pending** if the 2 nodes don't have enough capacity. The cluster won't automatically add more nodes unless you configure Cluster Autoscaler.

### Step 6: Check Nodes Again

```bash
kubectl get nodes
```

**Still 2 nodes** - no automatic scaling!

### Step 7: Cleanup

```bash
kubectl delete -f inflate-deployment.yaml
eksctl delete cluster --name events-cluster --region us-east-1
```

---

## Part 2: Auto Mode Cluster (With Auto Mode)

### Step 1: Create Cluster and Enable Auto Mode

**Option A: Using eksctl + AWS CLI (Recommended)**

First, create the cluster:
```bash
eksctl create cluster -f create-cluster-auto-mode.yaml
```

Then enable Auto Mode:
```bash
aws eks update-cluster-config \
  --name events-cluster-auto \
  --region us-east-1 \
  --compute-config enabled=true,nodePools=general-purpose,nodePools=system
```

**Option B: Using AWS CLI Only**

```bash
# Set variables
export CLUSTER_NAME=events-cluster-auto
export AWS_REGION=us-east-1
export ROLE_ARN=$(aws iam get-role --role-name EKSClusterRole --query 'Role.Arn' --output text)

# Get subnet IDs (use your VPC subnets)
export SUBNET_IDS=$(aws ec2 describe-subnets \
  --filters "Name=tag:Name,Values=*public*" \
  --query 'Subnets[0:2].SubnetId' \
  --output text | tr '\t' ',')

# Create cluster with Auto Mode
aws eks create-cluster \
  --name ${CLUSTER_NAME} \
  --region ${AWS_REGION} \
  --role-arn ${ROLE_ARN} \
  --resources-vpc-config subnetIds=${SUBNET_IDS} \
  --compute-config enabled=true,nodePools=general-purpose,nodePools=system \
  --kubernetes-version 1.34
```

Wait 10-15 minutes for cluster creation.

This creates a cluster with **Auto Mode enabled** - no node groups needed!

### Step 2: Configure kubectl

```bash
aws eks update-kubeconfig --name events-cluster-auto --region us-east-1
```

### Step 3: Check Initial Nodes

```bash
kubectl get nodes
```

You may see **0 nodes** or just system nodes - that's normal! Auto Mode provisions nodes on-demand.

### Step 4: Deploy Test Workload

```bash
kubectl apply -f inflate-deployment.yaml
```

### Step 5: Scale Up

```bash
kubectl scale deployment inflate --replicas=5
```

Watch what happens:
```bash
kubectl get pods -w
```

In another terminal, watch nodes:
```bash
kubectl get nodes -w
```

**Result:** Auto Mode **automatically provisions new nodes** to run your pods!

### Step 6: Check Nodes

```bash
kubectl get nodes
```

You'll see **new nodes automatically created** to handle the workload.

Check node labels:
```bash
kubectl get nodes --show-labels | grep eks.amazonaws.com/compute-type
```

You should see `eks.amazonaws.com/compute-type=auto`

### Step 7: Scale Down

```bash
kubectl scale deployment inflate --replicas=1
```

Watch nodes:
```bash
kubectl get nodes -w
```

**Result:** After 30-60 seconds, Auto Mode **automatically removes unnecessary nodes**!

### Step 8: Cleanup

```bash
kubectl delete -f inflate-deployment.yaml
eksctl delete cluster --name events-cluster-auto --region us-east-1
```

---

## Key Differences

| Feature | Traditional Cluster | Auto Mode Cluster |
|---------|-------------------|-------------------|
| **Initial Setup** | Define node groups | No node groups needed |
| **Node Management** | Manual or Cluster Autoscaler | Fully automatic |
| **Scaling Speed** | Slower (node group scaling) | Faster (direct provisioning) |
| **Cost Optimization** | Manual tuning needed | Automatic optimization |
| **Complexity** | Higher | Lower |
| **Control** | Full control | AWS managed |

---

## Commands Summary

### Traditional Cluster
```bash
# Create
eksctl create cluster -f create-cluster.yaml

# Update kubeconfig
aws eks update-kubeconfig --name events-cluster --region us-east-1

# Test
kubectl apply -f inflate-deployment.yaml
kubectl scale deployment inflate --replicas=5
kubectl get nodes  # Fixed number of nodes

# Cleanup
kubectl delete -f inflate-deployment.yaml
eksctl delete cluster --name events-cluster --region us-east-1
```

### Auto Mode Cluster
```bash
# Create cluster
eksctl create cluster -f create-cluster-auto-mode.yaml

# Enable Auto Mode
aws eks update-cluster-config \
  --name events-cluster-auto \
  --region us-east-1 \
  --compute-config enabled=true,nodePools=general-purpose,nodePools=system

# Update kubeconfig
aws eks update-kubeconfig --name events-cluster-auto --region us-east-1

# Test
kubectl apply -f inflate-deployment.yaml
kubectl scale deployment inflate --replicas=5
kubectl get nodes -w  # Watch nodes being added automatically!

# Scale down
kubectl scale deployment inflate --replicas=1
kubectl get nodes -w  # Watch nodes being removed automatically!

# Cleanup
kubectl delete -f inflate-deployment.yaml
eksctl delete cluster --name events-cluster-auto --region us-east-1
```

---

## What Students Will Learn

1. **Traditional clusters require manual capacity planning** - you must define node groups upfront
2. **Auto Mode eliminates capacity planning** - AWS provisions nodes automatically based on workload
3. **Auto Mode optimizes costs** - removes underutilized nodes automatically
4. **Auto Mode is faster** - provisions individual nodes instead of scaling node groups
5. **Auto Mode is simpler** - no Cluster Autoscaler or Karpenter installation needed

---

## Additional Experiments

### Test Different Instance Types

Auto Mode automatically selects appropriate instance types. Try:

```bash
# Deploy ARM workload
cat > arm-deployment.yaml << EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: arm-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: arm-app
  template:
    metadata:
      labels:
        app: arm-app
    spec:
      nodeSelector:
        kubernetes.io/arch: arm64
      containers:
      - name: nginx
        image: nginx:latest
        resources:
          requests:
            cpu: 500m
            memory: 512Mi
EOF

kubectl apply -f arm-deployment.yaml
kubectl get nodes -L kubernetes.io/arch
```

Auto Mode will provision ARM-based nodes automatically!

### Test GPU Workloads

```bash
# Deploy GPU workload
cat > gpu-deployment.yaml << EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: gpu-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: gpu-app
  template:
    metadata:
      labels:
        app: gpu-app
    spec:
      containers:
      - name: cuda
        image: nvidia/cuda:11.0-base
        resources:
          requests:
            nvidia.com/gpu: 1
EOF

kubectl apply -f gpu-deployment.yaml
```

Auto Mode will provision GPU instances automatically!

---

## Troubleshooting

### Pods Stuck in Pending (Auto Mode)

Check if pods have resource requests:
```bash
kubectl describe pod <pod-name>
```

Auto Mode requires resource requests to determine node size.

### Nodes Not Scaling Down

Check pod disruption budgets:
```bash
kubectl get pdb -A
```

Check for pods preventing node drain:
```bash
kubectl get pods --all-namespaces -o wide
```

### Verify Auto Mode is Enabled

```bash
aws eks describe-cluster \
  --name events-cluster-auto \
  --region us-east-1 \
  --query 'cluster.computeConfig'
```

Should show:
```json
{
    "enabled": true,
    "nodePools": ["general-purpose", "system"]
}
```
