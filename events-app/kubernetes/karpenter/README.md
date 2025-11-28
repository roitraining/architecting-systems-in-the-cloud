# Karpenter Autoscaling Lab

## Overview

Karpenter is a Kubernetes node autoscaler that automatically provisions right-sized compute resources based on your workload requirements. Unlike Cluster Autoscaler, Karpenter directly provisions nodes without relying on node groups.

**What You'll Learn:**
- Install Karpenter on an existing EKS cluster
- Configure NodePools and EC2NodeClasses
- Deploy workloads that trigger autoscaling
- Observe automatic node provisioning and deprovisioning

**Time Required:** 30-40 minutes

---

## Prerequisites

1. **Existing EKS cluster** (events-cluster) already running
2. **kubectl** configured to access the cluster
3. **Helm 3** installed
4. **AWS CLI** configured with appropriate permissions

---

## Step 1: Set Environment Variables

Set up variables for your cluster:

```bash
export CLUSTER_NAME=events-cluster
export AWS_REGION=us-east-1
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
export KARPENTER_VERSION=v0.33.0
```

Verify:
```bash
echo $CLUSTER_NAME
echo $AWS_REGION
echo $AWS_ACCOUNT_ID
```

---

## Step 2: Create IAM Roles for Karpenter

### 2.1 Create Karpenter Node IAM Role

This role will be used by nodes that Karpenter provisions.

```bash
cat > karpenter-node-trust-policy.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
```

Create the role:
```bash
aws iam create-role \
  --role-name KarpenterNodeRole-${CLUSTER_NAME} \
  --assume-role-policy-document file://karpenter-node-trust-policy.json
```

Attach required policies:
```bash
aws iam attach-role-policy \
  --role-name KarpenterNodeRole-${CLUSTER_NAME} \
  --policy-arn arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy

aws iam attach-role-policy \
  --role-name KarpenterNodeRole-${CLUSTER_NAME} \
  --policy-arn arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy

aws iam attach-role-policy \
  --role-name KarpenterNodeRole-${CLUSTER_NAME} \
  --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly

aws iam attach-role-policy \
  --role-name KarpenterNodeRole-${CLUSTER_NAME} \
  --policy-arn arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore
```

### 2.2 Create Karpenter Controller IAM Policy

Create the policy document:

```bash
cat > karpenter-controller-policy.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:CreateFleet",
        "ec2:CreateLaunchTemplate",
        "ec2:CreateTags",
        "ec2:DescribeAvailabilityZones",
        "ec2:DescribeImages",
        "ec2:DescribeInstances",
        "ec2:DescribeInstanceTypeOfferings",
        "ec2:DescribeInstanceTypes",
        "ec2:DescribeLaunchTemplates",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeSpotPriceHistory",
        "ec2:DescribeSubnets",
        "ec2:DeleteLaunchTemplate",
        "ec2:RunInstances",
        "ec2:TerminateInstances",
        "iam:PassRole",
        "iam:CreateInstanceProfile",
        "iam:DeleteInstanceProfile",
        "iam:AddRoleToInstanceProfile",
        "iam:RemoveRoleFromInstanceProfile",
        "iam:GetInstanceProfile",
        "pricing:GetProducts",
        "ssm:GetParameter"
      ],
      "Resource": "*"
    }
  ]
}
EOF
```

Create the policy:
```bash
aws iam create-policy \
  --policy-name KarpenterControllerPolicy-${CLUSTER_NAME} \
  --policy-document file://karpenter-controller-policy.json
```

### 2.3 Create IAM Role for Service Account (IRSA)

Get your cluster's OIDC provider:
```bash
export OIDC_PROVIDER=$(aws eks describe-cluster --name ${CLUSTER_NAME} \
  --query "cluster.identity.oidc.issuer" --output text | sed -e "s/^https:\/\///")

echo $OIDC_PROVIDER
```

Create trust policy for IRSA:
```bash
cat > karpenter-trust-policy.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::${AWS_ACCOUNT_ID}:oidc-provider/${OIDC_PROVIDER}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "${OIDC_PROVIDER}:aud": "sts.amazonaws.com",
          "${OIDC_PROVIDER}:sub": "system:serviceaccount:karpenter:karpenter"
        }
      }
    }
  ]
}
EOF
```

Create the controller role:
```bash
aws iam create-role \
  --role-name KarpenterControllerRole-${CLUSTER_NAME} \
  --assume-role-policy-document file://karpenter-trust-policy.json
```

Attach the policy:
```bash
aws iam attach-role-policy \
  --role-name KarpenterControllerRole-${CLUSTER_NAME} \
  --policy-arn arn:aws:iam::${AWS_ACCOUNT_ID}:policy/KarpenterControllerPolicy-${CLUSTER_NAME}
```

---

## Step 3: Tag Subnets for Karpenter

Karpenter needs to know which subnets to use. Tag your cluster's subnets:

Get subnet IDs:
```bash
export SUBNET_IDS=$(aws ec2 describe-subnets \
  --filters "Name=tag:alpha.eksctl.io/cluster-name,Values=${CLUSTER_NAME}" \
  --query 'Subnets[*].SubnetId' --output text)

echo $SUBNET_IDS
```

Tag each subnet:
```bash
for SUBNET_ID in $SUBNET_IDS; do
  aws ec2 create-tags \
    --resources $SUBNET_ID \
    --tags Key=karpenter.sh/discovery,Value=${CLUSTER_NAME}
done
```

Verify tags:
```bash
aws ec2 describe-subnets --subnet-ids $SUBNET_IDS \
  --query 'Subnets[*].[SubnetId,Tags[?Key==`karpenter.sh/discovery`].Value]' \
  --output table
```

---

## Step 4: Tag Security Groups for Karpenter

Get cluster security group:
```bash
export SECURITY_GROUP_ID=$(aws eks describe-cluster --name ${CLUSTER_NAME} \
  --query "cluster.resourcesVpcConfig.clusterSecurityGroupId" --output text)

echo $SECURITY_GROUP_ID
```

Tag the security group:
```bash
aws ec2 create-tags \
  --resources $SECURITY_GROUP_ID \
  --tags Key=karpenter.sh/discovery,Value=${CLUSTER_NAME}
```

Verify:
```bash
aws ec2 describe-security-groups --group-ids $SECURITY_GROUP_ID \
  --query 'SecurityGroups[*].[GroupId,Tags[?Key==`karpenter.sh/discovery`].Value]' \
  --output table
```

---

## Step 5: Update aws-auth ConfigMap

Allow Karpenter nodes to join the cluster:

```bash
kubectl edit configmap aws-auth -n kube-system
```

Add this entry under `mapRoles`:

```yaml
- groups:
  - system:bootstrappers
  - system:nodes
  rolearn: arn:aws:iam::${AWS_ACCOUNT_ID}:role/KarpenterNodeRole-${CLUSTER_NAME}
  username: system:node:{{EC2PrivateDNSName}}
```

**Note:** Replace `${AWS_ACCOUNT_ID}` and `${CLUSTER_NAME}` with actual values!

Or use this command to patch it:
```bash
kubectl get configmap aws-auth -n kube-system -o yaml > aws-auth-patch.yaml
```

Edit `aws-auth-patch.yaml` to add the role, then apply:
```bash
kubectl apply -f aws-auth-patch.yaml
```

---

## Step 6: Install Karpenter with Helm

### 6.1 Add Karpenter Helm Repository

```bash
helm repo add karpenter https://charts.karpenter.sh
helm repo update
```

### 6.2 Install Karpenter

```bash
helm install karpenter karpenter/karpenter \
  --namespace karpenter \
  --create-namespace \
  --version ${KARPENTER_VERSION} \
  --set serviceAccount.annotations."eks\.amazonaws\.com/role-arn"="arn:aws:iam::${AWS_ACCOUNT_ID}:role/KarpenterControllerRole-${CLUSTER_NAME}" \
  --set settings.clusterName=${CLUSTER_NAME} \
  --set settings.clusterEndpoint=$(aws eks describe-cluster --name ${CLUSTER_NAME} --query "cluster.endpoint" --output text) \
  --set settings.interruptionQueue=${CLUSTER_NAME} \
  --wait
```

### 6.3 Verify Installation

Check Karpenter pods:
```bash
kubectl get pods -n karpenter
```

Expected output:
```
NAME                         READY   STATUS    RESTARTS   AGE
karpenter-xxxxxxxxxx-xxxxx   1/1     Running   0          30s
karpenter-xxxxxxxxxx-xxxxx   1/1     Running   0          30s
```

Check logs:
```bash
kubectl logs -f -n karpenter -l app.kubernetes.io/name=karpenter
```

---

## Step 7: Create NodePool and EC2NodeClass

Apply the NodePool configuration:

```bash
kubectl apply -f nodepool.yaml
```

Apply the EC2NodeClass configuration:

```bash
kubectl apply -f ec2nodeclass.yaml
```

Verify:
```bash
kubectl get nodepool
kubectl get ec2nodeclass
```

---

## Step 8: Deploy Test Workload

Deploy a sample application that will trigger autoscaling:

```bash
kubectl apply -f inflate-deployment.yaml
```

Watch nodes being created:
```bash
kubectl get nodes -w
```

Watch pods:
```bash
kubectl get pods -w
```

Check Karpenter logs to see provisioning:
```bash
kubectl logs -f -n karpenter -l app.kubernetes.io/name=karpenter
```

---

## Step 9: Scale Up Test

Scale the deployment to trigger more nodes:

```bash
kubectl scale deployment inflate --replicas=10
```

Watch Karpenter provision new nodes:
```bash
kubectl get nodes -w
```

Check node details:
```bash
kubectl get nodes -L karpenter.sh/nodepool
```

---

## Step 10: Scale Down Test

Scale down to trigger deprovisioning:

```bash
kubectl scale deployment inflate --replicas=1
```

Watch Karpenter remove unnecessary nodes (takes ~30 seconds):
```bash
kubectl get nodes -w
```

---

## Step 11: View Karpenter Metrics

Check Karpenter events:
```bash
kubectl get events -n karpenter --sort-by='.lastTimestamp'
```

Describe a Karpenter-provisioned node:
```bash
kubectl describe node <node-name>
```

---

## Cleanup

### Remove Test Deployment

```bash
kubectl delete -f inflate-deployment.yaml
```

Wait for Karpenter to deprovision nodes (~30 seconds).

### Uninstall Karpenter (Optional)

```bash
helm uninstall karpenter -n karpenter
kubectl delete namespace karpenter
```

### Delete IAM Resources (Optional)

```bash
aws iam detach-role-policy \
  --role-name KarpenterControllerRole-${CLUSTER_NAME} \
  --policy-arn arn:aws:iam::${AWS_ACCOUNT_ID}:policy/KarpenterControllerPolicy-${CLUSTER_NAME}

aws iam delete-role --role-name KarpenterControllerRole-${CLUSTER_NAME}

aws iam delete-policy \
  --policy-arn arn:aws:iam::${AWS_ACCOUNT_ID}:policy/KarpenterControllerPolicy-${CLUSTER_NAME}

aws iam detach-role-policy \
  --role-name KarpenterNodeRole-${CLUSTER_NAME} \
  --policy-arn arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy

aws iam detach-role-policy \
  --role-name KarpenterNodeRole-${CLUSTER_NAME} \
  --policy-arn arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy

aws iam detach-role-policy \
  --role-name KarpenterNodeRole-${CLUSTER_NAME} \
  --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly

aws iam detach-role-policy \
  --role-name KarpenterNodeRole-${CLUSTER_NAME} \
  --policy-arn arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore

aws iam delete-role --role-name KarpenterNodeRole-${CLUSTER_NAME}
```

---

## Troubleshooting

### Pods Not Scheduling

Check NodePool:
```bash
kubectl describe nodepool default
```

Check Karpenter logs:
```bash
kubectl logs -n karpenter -l app.kubernetes.io/name=karpenter
```

### Nodes Not Joining Cluster

Verify aws-auth ConfigMap:
```bash
kubectl get configmap aws-auth -n kube-system -o yaml
```

Check IAM role:
```bash
aws iam get-role --role-name KarpenterNodeRole-${CLUSTER_NAME}
```

### Karpenter Not Provisioning

Check subnet tags:
```bash
aws ec2 describe-subnets --filters "Name=tag:karpenter.sh/discovery,Values=${CLUSTER_NAME}"
```

Check security group tags:
```bash
aws ec2 describe-security-groups --filters "Name=tag:karpenter.sh/discovery,Values=${CLUSTER_NAME}"
```

---

## Key Concepts

**NodePool**: Defines the constraints and requirements for nodes (instance types, capacity type, limits)

**EC2NodeClass**: Defines AWS-specific configuration (AMI, security groups, subnets, IAM role)

**Provisioning**: Karpenter watches for unschedulable pods and provisions nodes to run them

**Deprovisioning**: Karpenter removes nodes that are underutilized or empty after a consolidation period

**Consolidation**: Karpenter continuously optimizes node utilization by moving pods and removing unnecessary nodes

---

## Additional Resources

- [Karpenter Documentation](https://karpenter.sh/)
- [Karpenter Best Practices](https://aws.github.io/aws-eks-best-practices/karpenter/)
- [EKS Workshop - Karpenter](https://www.eksworkshop.com/docs/autoscaling/compute/karpenter/)
