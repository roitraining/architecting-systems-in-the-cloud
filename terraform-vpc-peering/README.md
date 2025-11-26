# VPC Peering with Terraform

This Terraform configuration creates two VPCs in AWS and establishes a VPC peering connection between them, demonstrating Infrastructure as Code (IaC) principles.

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        AWS Region                            │
│                                                              │
│  ┌────────────────────────┐    ┌────────────────────────┐  │
│  │   VPC 1 (Production)   │    │  VPC 2 (Development)   │  │
│  │   CIDR: 10.1.0.0/16    │◄──►│   CIDR: 10.2.0.0/16    │  │
│  │                        │    │                        │  │
│  │  ┌──────────────────┐  │    │  ┌──────────────────┐  │  │
│  │  │ Subnet           │  │    │  │ Subnet           │  │  │
│  │  │ 10.1.1.0/24      │  │    │  │ 10.2.1.0/24      │  │  │
│  │  └──────────────────┘  │    │  └──────────────────┘  │  │
│  │                        │    │                        │  │
│  │  ┌──────────────────┐  │    │  ┌──────────────────┐  │  │
│  │  │ Security Group   │  │    │  │ Security Group   │  │  │
│  │  │ - SSH (22)       │  │    │  │ - SSH (22)       │  │  │
│  │  │ - All from VPC 2 │  │    │  │ - All from VPC 1 │  │  │
│  │  └──────────────────┘  │    │  └──────────────────┘  │  │
│  │                        │    │                        │  │
│  │  ┌──────────────────┐  │    │  ┌──────────────────┐  │  │
│  │  │ Internet Gateway │  │    │  │ Internet Gateway │  │  │
│  │  └──────────────────┘  │    │  └──────────────────┘  │  │
│  └────────────────────────┘    └────────────────────────┘  │
│              │                            │                 │
│              └────────VPC Peering─────────┘                 │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

## 📋 What Gets Created

- **2 VPCs** with non-overlapping CIDR blocks
- **2 Subnets** (one in each VPC)
- **2 Internet Gateways** (one per VPC)
- **2 Route Tables** with routes for internet and peering
- **1 VPC Peering Connection** (auto-accepted)
- **2 Security Groups** allowing traffic between VPCs

## 🚀 Quick Start

### Prerequisites

- AWS Account with appropriate permissions
- AWS CLI configured with credentials
- Terraform installed (version >= 1.0)

### Deployment Steps

```bash
# 1. Navigate to the directory
cd terraform-vpc-peering

# 2. Initialize Terraform
terraform init

# 3. Review the plan
terraform plan

# 4. Apply the configuration
terraform apply

# 5. View outputs
terraform output

# 6. Cleanup when done
terraform destroy
```

## 📝 Detailed Instructions

### Step 1: Install Terraform

**On Linux/macOS:**
```bash
# Download and install
wget https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip
unzip terraform_1.6.0_linux_amd64.zip
sudo mv terraform /usr/local/bin/
terraform version
```

**On Windows:**
```powershell
# Using Chocolatey
choco install terraform

# Or download from: https://www.terraform.io/downloads
```

**In AWS CloudShell:**
```bash
# Terraform is pre-installed in CloudShell!
terraform version
```

### Step 2: Configure AWS Credentials

```bash
# Option 1: AWS CLI (if not already configured)
aws configure

# Option 2: Environment variables
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_DEFAULT_REGION="us-east-1"

# Option 3: Use CloudShell (credentials already configured)
```

### Step 3: Customize Variables (Optional)

```bash
# Copy example file
cp terraform.tfvars.example terraform.tfvars

# Edit with your values
nano terraform.tfvars
```

### Step 4: Initialize Terraform

```bash
terraform init
```

This downloads the AWS provider and prepares your workspace.

### Step 5: Plan the Deployment

```bash
terraform plan
```

Review what will be created. You should see:
- 2 VPCs
- 2 Subnets
- 2 Internet Gateways
- 2 Route Tables
- 2 Route Table Associations
- 1 VPC Peering Connection
- 2 Security Groups

### Step 6: Apply the Configuration

```bash
terraform apply
```

Type `yes` when prompted. Deployment takes ~2-3 minutes.

### Step 7: View Outputs

```bash
# View all outputs
terraform output

# View specific output
terraform output vpc_1_id

# View summary
terraform output summary
```

## 🧪 Testing the VPC Peering

### Option 1: Launch Test EC2 Instances

```bash
# Get the subnet and security group IDs
VPC1_SUBNET=$(terraform output -raw vpc_1_subnet_id)
VPC1_SG=$(terraform output -raw vpc_1_security_group_id)
VPC2_SUBNET=$(terraform output -raw vpc_2_subnet_id)
VPC2_SG=$(terraform output -raw vpc_2_security_group_id)

# Launch instance in VPC 1
aws ec2 run-instances \
  --image-id ami-0c55b159cbfafe1f0 \
  --instance-type t2.micro \
  --subnet-id $VPC1_SUBNET \
  --security-group-ids $VPC1_SG \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=VPC1-Test}]'

# Launch instance in VPC 2
aws ec2 run-instances \
  --image-id ami-0c55b159cbfafe1f0 \
  --instance-type t2.micro \
  --subnet-id $VPC2_SUBNET \
  --security-group-ids $VPC2_SG \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=VPC2-Test}]'
```

### Option 2: Test with Ping

```bash
# SSH into instance in VPC 1
ssh ec2-user@<vpc1-instance-public-ip>

# Ping instance in VPC 2 using private IP
ping <vpc2-instance-private-ip>

# Should receive responses! 🎉
```

## 📊 Understanding the Configuration

### VPC CIDR Blocks

- **VPC 1**: `10.1.0.0/16` (65,536 IP addresses)
- **VPC 2**: `10.2.0.0/16` (65,536 IP addresses)

These ranges **do not overlap**, which is required for VPC peering.

### Security Groups

Both security groups allow:
- **SSH (port 22)** from anywhere (for demo purposes)
- **All traffic** from the peered VPC
- **ICMP (ping)** from the peered VPC
- **All outbound traffic**

### Route Tables

Each route table has two routes:
1. **Internet route**: `0.0.0.0/0` → Internet Gateway
2. **Peering route**: `<other-vpc-cidr>` → VPC Peering Connection

## 🎓 Learning Objectives

Students will learn:
- ✅ Infrastructure as Code with Terraform
- ✅ VPC creation and configuration
- ✅ VPC peering concepts
- ✅ Security group rules
- ✅ Route table configuration
- ✅ Terraform state management
- ✅ Resource dependencies

## 📁 File Structure

```
terraform-vpc-peering/
├── main.tf                    # Main Terraform configuration
├── variables.tf               # Variable definitions
├── outputs.tf                 # Output definitions
├── terraform.tfvars.example   # Example variables file
├── .gitignore                # Git ignore rules
└── README.md                 # This file
```

## 🔧 Terraform Commands Reference

| Command | Description |
|---------|-------------|
| `terraform init` | Initialize working directory |
| `terraform plan` | Preview changes |
| `terraform apply` | Create/update resources |
| `terraform destroy` | Delete all resources |
| `terraform output` | Show output values |
| `terraform show` | Show current state |
| `terraform fmt` | Format configuration files |
| `terraform validate` | Validate configuration |

## 🐛 Troubleshooting

### Error: "CIDR blocks overlap"
**Solution**: Ensure VPC CIDR blocks don't overlap. Use different ranges like `10.1.0.0/16` and `10.2.0.0/16`.

### Error: "Insufficient permissions"
**Solution**: Ensure your AWS credentials have permissions for VPC, EC2, and networking operations.

### Error: "Region not available"
**Solution**: Change the `aws_region` variable to a region you have access to.

### Peering connection not working
**Solution**: 
1. Check route tables have peering routes
2. Verify security groups allow traffic
3. Ensure CIDR blocks don't overlap

## 💰 Cost Information

This demo creates:
- **VPCs**: Free
- **Subnets**: Free
- **Internet Gateways**: Free (if no data transfer)
- **VPC Peering**: Free (data transfer within same region)
- **Security Groups**: Free

**Total cost**: $0 (if no EC2 instances or data transfer)

If you launch EC2 instances for testing:
- **t2.micro**: Free tier eligible (750 hours/month)
- **After free tier**: ~$0.01/hour

## 🧹 Cleanup

**Important**: Always clean up resources to avoid charges!

```bash
# Destroy all resources
terraform destroy

# Type 'yes' when prompted
```

This will delete:
- VPC peering connection
- Security groups
- Route tables
- Internet gateways
- Subnets
- VPCs

## 🎯 Extension Activities

1. **Add more subnets**: Create public and private subnets in each VPC
2. **Add NAT Gateways**: Enable private subnet internet access
3. **Add VPC Endpoints**: Connect to AWS services privately
4. **Add Network ACLs**: Implement additional network security
5. **Multi-region peering**: Peer VPCs across different regions
6. **Add EC2 instances**: Automate instance creation with Terraform

## 📚 Additional Resources

- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS VPC Peering Guide](https://docs.aws.amazon.com/vpc/latest/peering/)
- [Terraform Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/)

## ✅ Success Criteria

You've successfully completed this lab when:
- ✅ Terraform apply completes without errors
- ✅ Two VPCs are created with different CIDR blocks
- ✅ VPC peering connection status is "active"
- ✅ Route tables include peering routes
- ✅ Security groups allow cross-VPC traffic
- ✅ (Optional) EC2 instances can ping each other across VPCs
- ✅ All resources are destroyed with `terraform destroy`

---

**Questions?** Check the troubleshooting section or review the Terraform documentation!
