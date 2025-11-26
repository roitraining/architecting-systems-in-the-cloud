# Terraform Labs - Progressive Infrastructure Learning

Three connected labs teaching Terraform, VPC networking, VPC peering, IAM roles, and S3 permissions.

## 🎯 Overview

These labs build on each other to create a complete AWS infrastructure scenario:

1. **Lab 1**: Create 2 isolated VPCs with EC2 instances (no connectivity)
2. **Lab 2**: Add VPC peering to connect the networks
3. **Lab 3**: Add IAM roles and S3 access to demonstrate permissions

## 📚 Lab Structure

```
terraform-lab/
├── lab1-vpc-ec2/          # Create VPCs and EC2 instances
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── README.md
├── lab2-vpc-peering/      # Add VPC peering connection
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── README.md
├── lab3-iam-s3/          # Add IAM roles and S3 bucket
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── README.md
└── README.md             # This file
```

## ⏱️ Time Required

- **Lab 1**: 30 minutes (VPC and EC2 setup)
- **Lab 2**: 20 minutes (VPC peering)
- **Lab 3**: 25 minutes (IAM and S3)
- **Total**: ~75 minutes

## 🚀 Quick Start

### Prerequisites

- AWS Account
- AWS CLI configured OR use AWS CloudShell
- Terraform installed (or use CloudShell)

### Lab Sequence

**Important**: Complete labs in order!

```bash
# Lab 1: Create VPCs and EC2 instances
cd lab1-vpc-ec2
terraform init
terraform plan
terraform apply
terraform output  # Note the instance IPs

# Lab 2: Add VPC peering
cd ../lab2-vpc-peering
terraform init
terraform plan
terraform apply
terraform output  # Test connectivity instructions

# Lab 3: Add IAM and S3
cd ../lab3-iam-s3
terraform init
terraform plan
terraform apply
terraform output  # Follow testing instructions
```

## 📖 Detailed Lab Descriptions

### Lab 1: VPC and EC2 Setup

**What you'll create**:
- 2 VPCs with different CIDR blocks (10.1.0.0/16 and 10.2.0.0/16)
- 2 subnets (one per VPC)
- 2 Internet Gateways
- 2 Route Tables
- 2 Security Groups
- 2 EC2 instances (Amazon Linux 2023, t2.micro)

**What you'll learn**:
- Creating VPCs with Terraform
- Launching EC2 instances
- Network isolation
- Security groups

**Key test**: Try to ping between instances → **FAILS** (no connectivity)

### Lab 2: VPC Peering

**What you'll create**:
- VPC peering connection
- Routes in both route tables

**What you'll learn**:
- VPC peering concepts
- Route table management
- Using `terraform_remote_state` to reference other labs
- Network connectivity

**Key test**: Ping between instances → **WORKS!** ✓

### Lab 3: IAM and S3

**What you'll create**:
- S3 bucket with test file
- IAM role with S3 read-only permissions
- EC2 instance profile

**What you'll learn**:
- IAM roles for EC2
- Instance profiles
- S3 permissions
- Testing permission boundaries
- Dynamic permission changes

**Key tests**:
1. Access S3 without role → **FAILS**
2. Attach role, access S3 → **WORKS!** ✓
3. Try to write to S3 → **FAILS**
4. Add write permissions → **WORKS!** ✓

## 🎓 Learning Objectives

By completing these labs, students will:
- ✅ Understand Terraform workflow (init, plan, apply, destroy)
- ✅ Create and manage VPCs
- ✅ Launch and configure EC2 instances
- ✅ Implement VPC peering
- ✅ Create and attach IAM roles
- ✅ Test permission boundaries
- ✅ Use Terraform remote state
- ✅ Build infrastructure progressively

## 💰 Cost Information

- **VPCs, Subnets, IGWs**: Free
- **VPC Peering**: Free (same region)
- **EC2 t2.micro**: Free tier eligible (750 hrs/month)
- **S3 Bucket**: Free (minimal storage)
- **IAM Roles**: Free

**Total**: $0 (within free tier)

## 🔑 Key Concepts

### Terraform Remote State
Labs 2 and 3 use `terraform_remote_state` to reference Lab 1 outputs:

```hcl
data "terraform_remote_state" "lab1" {
  backend = "local"
  config = {
    path = "../lab1-vpc-ec2/terraform.tfstate"
  }
}
```

This allows labs to be independent while sharing resources.

### Progressive Infrastructure
Each lab adds to the previous:
- Lab 1: Foundation (VPCs, EC2)
- Lab 2: Connectivity (Peering)
- Lab 3: Permissions (IAM, S3)

### Separate State Files
Each lab has its own state file, teaching:
- State management
- Resource dependencies
- Modular infrastructure

## 🧹 Cleanup

**Important**: Destroy in reverse order!

```bash
# Step 1: Destroy Lab 3
cd lab3-iam-s3
terraform destroy

# Step 2: Destroy Lab 2
cd ../lab2-vpc-peering
terraform destroy

# Step 3: Destroy Lab 1
cd ../lab1-vpc-ec2
terraform destroy
```

## 🐛 Troubleshooting

### Issue: "Error acquiring the state lock"
**Solution**: Another terraform process is running. Wait or remove the lock file.

### Issue: "No state file found" in Lab 2 or 3
**Solution**: Complete Lab 1 first. Labs must be done in order.

### Issue: Can't ping between instances after Lab 2
**Solution**: 
- Verify peering connection is active
- Check route tables have peering routes
- Ensure security groups allow ICMP

### Issue: S3 access denied even with role attached
**Solution**: 
- Wait 10-15 seconds after attaching role
- Reconnect to the instance
- Verify role is attached in EC2 console

## 📚 Additional Resources

- [Terraform Documentation](https://www.terraform.io/docs)
- [AWS VPC Peering](https://docs.aws.amazon.com/vpc/latest/peering/)
- [IAM Roles for EC2](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_use_switch-role-ec2.html)
- [Terraform Remote State](https://www.terraform.io/docs/language/state/remote-state-data.html)

## ✅ Success Criteria

Students successfully complete the labs when they:
- ✅ Deploy all 3 labs in sequence
- ✅ Verify connectivity fails in Lab 1
- ✅ Verify connectivity works in Lab 2
- ✅ Test S3 access without role (fails)
- ✅ Test S3 access with role (works)
- ✅ Test write permissions (fails, then works)
- ✅ Understand Terraform remote state
- ✅ Clean up all resources

---

**Ready to start?** Open `lab1-vpc-ec2/README.md` and begin!
