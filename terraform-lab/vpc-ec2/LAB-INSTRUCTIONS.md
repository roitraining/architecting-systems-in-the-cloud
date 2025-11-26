# Lab 1: VPC and EC2 Setup

## Overview

In this lab, you'll create two isolated Virtual Private Clouds (VPCs) with EC2 instances. You'll learn that by default, VPCs are completely isolated from each other - instances in different VPCs cannot communicate even though they're in the same AWS account.

**What You'll Build:**
- 2 VPCs with different CIDR blocks (10.1.0.0/16 and 10.2.0.0/16)
- 1 subnet in each VPC
- 1 EC2 instance in each VPC
- Internet Gateways for external connectivity
- Security groups allowing SSH and ICMP (ping)

**Time Required:** 20-30 minutes

---

## Prerequisites

1. **AWS Account** with appropriate permissions
2. **Terraform Installed** (version >= 1.0)
3. **AWS CLI Configured** with credentials

---

## Terraform Commands - Step by Step

### Step 1: Navigate to Lab Directory

```bash
cd terraform-lab/vpc-ec2
```

---

### Step 2: Initialize Terraform

Download the AWS provider and initialize the working directory:

```bash
terraform init
```

**Expected Output:**
```
Initializing the backend...
Initializing provider plugins...
- Finding hashicorp/aws versions matching "~> 5.0"...
- Installing hashicorp/aws v5.x.x...

Terraform has been successfully initialized!
```

✅ **Success Indicator:** You should see "Terraform has been successfully initialized!"

---

### Step 3: Validate Configuration

Check that your Terraform files are syntactically correct:

```bash
terraform validate
```

**Expected Output:**
```
Success! The configuration is valid.
```

---

### Step 4: Format Code (Optional)

Format your Terraform files to follow standard conventions:

```bash
terraform fmt
```

This ensures consistent formatting across all `.tf` files.

---

### Step 5: Review Execution Plan

See what Terraform will create WITHOUT actually creating it:

```bash
terraform plan
```

**Expected Output:**
```
Terraform will perform the following actions:

  # aws_instance.vpc_1_instance will be created
  # aws_instance.vpc_2_instance will be created
  # aws_vpc.vpc_1 will be created
  # aws_vpc.vpc_2 will be created
  ... (and more resources)

Plan: 16 to add, 0 to change, 0 to destroy.
```

✅ **Success Indicator:** Should show **16 resources to add**

**Review the plan carefully:**
- 2 VPCs
- 2 Subnets
- 2 Internet Gateways
- 2 Route Tables
- 2 Route Table Associations
- 2 Security Groups
- 2 EC2 Instances

---

### Step 6: Apply Configuration (Create Resources)

Create all the infrastructure:

```bash
terraform apply
```

**What happens:**
1. Terraform shows you the plan again
2. Prompts: `Do you want to perform these actions?`
3. Type: **`yes`** and press Enter
4. Wait 2-3 minutes while resources are created

**Expected Output:**
```
aws_vpc.vpc_1: Creating...
aws_vpc.vpc_2: Creating...
aws_vpc.vpc_1: Creation complete after 3s [id=vpc-0abc123...]
aws_vpc.vpc_2: Creation complete after 3s [id=vpc-0def456...]
...
aws_instance.vpc_1_instance: Still creating... [10s elapsed]
aws_instance.vpc_2_instance: Still creating... [10s elapsed]
aws_instance.vpc_1_instance: Creation complete after 32s [id=i-0abc123...]
aws_instance.vpc_2_instance: Creation complete after 33s [id=i-0def456...]

Apply complete! Resources: 16 added, 0 changed, 0 destroyed.

Outputs:

vpc_1_instance_private_ip = "10.1.1.123"
vpc_1_instance_public_ip = "54.123.45.67"
vpc_2_instance_private_ip = "10.2.1.234"
vpc_2_instance_public_ip = "54.234.56.78"
...
```

✅ **Success Indicator:** "Apply complete! Resources: 16 added"

**📝 IMPORTANT:** Copy the private IP addresses - you'll need them for testing!

---

### Step 7: View Outputs

Display all output values:

```bash
terraform output
```

**View specific outputs:**

```bash
# VPC IDs
terraform output vpc_1_id
terraform output vpc_2_id

# Instance Private IPs
terraform output vpc_1_instance_private_ip
terraform output vpc_2_instance_private_ip

# Instance Public IPs
terraform output vpc_1_instance_public_ip
terraform output vpc_2_instance_public_ip

# Connection instructions
terraform output connection_instructions
```

---

### Step 8: Inspect Terraform State

View all resources managed by Terraform:

```bash
terraform state list
```

**Expected Output:**
```
data.aws_ami.amazon_linux_2023
data.aws_availability_zones.available
aws_instance.vpc_1_instance
aws_instance.vpc_2_instance
aws_internet_gateway.vpc_1_igw
aws_internet_gateway.vpc_2_igw
aws_route_table.vpc_1_rt
aws_route_table.vpc_2_rt
aws_route_table_association.vpc_1_rta
aws_route_table_association.vpc_2_rta
aws_security_group.vpc_1_sg
aws_security_group.vpc_2_sg
aws_subnet.vpc_1_subnet
aws_subnet.vpc_2_subnet
aws_vpc.vpc_1
aws_vpc.vpc_2
```

**View details of a specific resource:**

```bash
terraform state show aws_vpc.vpc_1
```

**View details of an instance:**

```bash
terraform state show aws_instance.vpc_1_instance
```

---

### Step 9: Verify in AWS Console

1. Open AWS Console → **VPC Dashboard** → **Your VPCs**
   - Verify: `terraform-lab-vpc-1` (10.1.0.0/16)
   - Verify: `terraform-lab-vpc-2` (10.2.0.0/16)

2. Navigate to **EC2 Dashboard** → **Instances**
   - Verify: `terraform-lab-vpc-1-instance` (Running)
   - Verify: `terraform-lab-vpc-2-instance` (Running)

---

## Test Connectivity (Expected to FAIL)

### Step 10: Connect to VPC 1 Instance

**Using EC2 Instance Connect (Browser-based - Recommended):**

1. AWS Console → **EC2** → **Instances**
2. Select **terraform-lab-vpc-1-instance**
3. Click **Connect** button
4. Choose **EC2 Instance Connect** tab
5. Click **Connect**
6. Browser terminal opens

---

### Step 11: Test Ping to VPC 2 (Will FAIL)

Once connected to VPC 1 instance, ping VPC 2 instance:

```bash
# Replace with YOUR VPC 2 private IP from terraform output
ping 10.2.1.234
```

**Expected Result - FAILURE:**
```
PING 10.2.1.234 (10.2.1.234) 56(84) bytes of data.
^C
--- 10.2.1.234 ping statistics ---
5 packets transmitted, 0 received, 100% packet loss
```

Press `Ctrl+C` to stop.

**Why does this fail?**
- ❌ No route between VPCs
- ✅ Security groups allow ICMP
- ✅ Instances are running
- **Problem:** VPCs are isolated by default!

---

## Additional Terraform Commands

### View Current State

```bash
# Show all resources in human-readable format
terraform show

# Show state in JSON format
terraform show -json

# Show specific resource
terraform state show aws_instance.vpc_1_instance
```

---

### Refresh State

Sync Terraform state with real AWS resources:

```bash
terraform refresh
```

This updates the state file without making changes to infrastructure.

---

### View Execution Plan Again

```bash
terraform plan
```

Should show: `No changes. Your infrastructure matches the configuration.`

---

### Modify Variables (Optional)

Create a `terraform.tfvars` file to override defaults:

```bash
# Create terraform.tfvars
cat > terraform.tfvars << EOF
aws_region = "us-west-2"
project_name = "my-lab"
instance_type = "t3.micro"
EOF
```

Then run:
```bash
terraform plan
terraform apply
```

---

### Target Specific Resources (Advanced)

Apply changes to only specific resources:

```bash
# Only create/update VPC 1
terraform apply -target=aws_vpc.vpc_1

# Only create/update VPC 1 instance
terraform apply -target=aws_instance.vpc_1_instance
```

---

### View Resource Dependencies

```bash
# Generate dependency graph (requires graphviz)
terraform graph | dot -Tpng > graph.png
```

---

## Cleanup Commands

### Preview Destruction

See what will be destroyed WITHOUT actually destroying:

```bash
terraform plan -destroy
```

---

### Destroy All Resources

**⚠️ WARNING:** Only run this if you're NOT continuing to Lab 2!

```bash
terraform destroy
```

**Steps:**
1. Terraform shows destruction plan
2. Type: **`yes`** to confirm
3. Wait 2-3 minutes

**Expected Output:**
```
aws_instance.vpc_2_instance: Destroying... [id=i-0def456...]
aws_instance.vpc_1_instance: Destroying... [id=i-0abc123...]
...
Destroy complete! Resources: 16 destroyed.
```

---

### Destroy Specific Resources (Advanced)

```bash
# Destroy only VPC 1 instance
terraform destroy -target=aws_instance.vpc_1_instance

# Destroy multiple specific resources
terraform destroy -target=aws_instance.vpc_1_instance -target=aws_instance.vpc_2_instance
```

---

### Auto-Approve (Skip Confirmation)

**⚠️ Use with caution!**

```bash
# Apply without confirmation prompt
terraform apply -auto-approve

# Destroy without confirmation prompt
terraform destroy -auto-approve
```

---

## Understanding the Architecture

**What You've Built:**

```
┌─────────────────────────────────────────────────────────────┐
│                         AWS Account                          │
│                                                              │
│  ┌─────────────────────┐      ┌─────────────────────┐      │
│  │   VPC 1             │      │   VPC 2             │      │
│  │   10.1.0.0/16       │      │   10.2.0.0/16       │      │
│  │                     │      │                     │      │
│  │  ┌──────────────┐   │      │  ┌──────────────┐   │      │
│  │  │ Subnet       │   │      │  │ Subnet       │   │      │
│  │  │ 10.1.1.0/24  │   │      │  │ 10.2.1.0/24  │   │      │
│  │  │              │   │      │  │              │   │      │
│  │  │  ┌────────┐  │   │      │  │  ┌────────┐  │   │      │
│  │  │  │ EC2    │  │   │      │  │  │ EC2    │  │   │      │
│  │  │  │ 10.1.1.x│◄─┼──┼──X──┼──┼──┼►│10.2.1.x│  │   │      │
│  │  │  └────────┘  │   │      │  │  └────────┘  │   │      │
│  │  └──────────────┘   │      │  └──────────────┘   │      │
│  │         │            │      │         │            │      │
│  │    ┌────▼────┐       │      │    ┌────▼────┐       │      │
│  │    │   IGW   │       │      │    │   IGW   │       │      │
│  │    └────┬────┘       │      │    └────┬────┘       │      │
│  └─────────┼────────────┘      └─────────┼────────────┘      │
│            │                              │                   │
└────────────┼──────────────────────────────┼───────────────────┘
             │                              │
             └──────────┬───────────────────┘
                        │
                   Internet
```

**Key Points:**
- ❌ No route between VPCs (marked with X)
- ✅ Both VPCs can access the internet via IGW
- ✅ Security groups allow ICMP traffic
- ❌ Routing is missing - Lab 2 will fix this!

---

## Quick Reference - All Commands in Order

```bash
# 1. Navigate to directory
cd terraform-lab/vpc-ec2

# 2. Initialize Terraform
terraform init

# 3. Validate configuration
terraform validate

# 4. Format code (optional)
terraform fmt

# 5. Preview changes
terraform plan

# 6. Create infrastructure
terraform apply
# Type: yes

# 7. View outputs
terraform output

# 8. View state
terraform state list

# 9. View specific resource
terraform state show aws_instance.vpc_1_instance

# 10. Connect to instance and test (in AWS Console)
# EC2 → Instances → Connect → EC2 Instance Connect
# Then: ping <VPC_2_PRIVATE_IP>

# 11. When done with ALL labs, destroy
terraform destroy
# Type: yes
```

---

## Troubleshooting Terraform Commands

### Error: Terraform Not Initialized

```bash
# Error: Backend initialization required
# Solution:
terraform init
```

---

### Error: State Lock

```bash
# Error: Error acquiring the state lock
# Solution: Wait or force unlock (use carefully!)
terraform force-unlock <LOCK_ID>
```

---

### Error: AWS Credentials Not Found

```bash
# Error: No valid credential sources found
# Solution: Configure AWS CLI
aws configure
```

Or set environment variables:
```bash
export AWS_ACCESS_KEY_ID="your-key"
export AWS_SECRET_ACCESS_KEY="your-secret"
export AWS_DEFAULT_REGION="us-east-1"
```

---

### Error: Resource Already Exists

```bash
# Error: Resource already exists
# Solution: Import existing resource
terraform import aws_vpc.vpc_1 vpc-0abc123

# Or remove from state and let Terraform recreate
terraform state rm aws_vpc.vpc_1
terraform apply
```

---

### Error: Insufficient IAM Permissions

```bash
# Error: UnauthorizedOperation
# Solution: Ensure IAM user has these permissions:
# - ec2:CreateVpc
# - ec2:CreateSubnet
# - ec2:RunInstances
# - ec2:CreateSecurityGroup
# - ec2:AuthorizeSecurityGroupIngress
```

---

### Fix Corrupted State

```bash
# Pull remote state
terraform state pull > backup.tfstate

# Push corrected state
terraform state push backup.tfstate
```

---

### Recover from Failed Apply

```bash
# If apply fails midway:
terraform refresh
terraform plan
terraform apply
```

---

### Remove Resource from State (Without Destroying)

```bash
# Remove from Terraform management but keep in AWS
terraform state rm aws_instance.vpc_1_instance
```

---

### Move Resource in State

```bash
# Rename resource in state
terraform state mv aws_instance.old_name aws_instance.new_name
```

---

## Common Terraform Workflow Patterns

### Standard Workflow

```bash
terraform init      # Initialize (once)
terraform plan      # Preview changes
terraform apply     # Apply changes
terraform output    # View outputs
```

---

### Development Workflow

```bash
terraform fmt       # Format code
terraform validate  # Validate syntax
terraform plan      # Check changes
terraform apply     # Apply if good
```

---

### Debugging Workflow

```bash
terraform plan -out=plan.tfplan    # Save plan
terraform show plan.tfplan         # Inspect plan
terraform apply plan.tfplan        # Apply saved plan
```

---

### State Management Workflow

```bash
terraform state list               # List resources
terraform state show <resource>    # Show details
terraform state pull > backup      # Backup state
```

---

## Key Takeaways

✅ **VPCs are isolated by default** - instances cannot communicate across VPCs

✅ **Terraform workflow**: init → validate → plan → apply → output

✅ **State management** - Terraform tracks all resources in state file

✅ **Outputs enable lab progression** - Lab 2 will reference these resources

✅ **Security groups ≠ routing** - Both are needed for connectivity

---

## Next Steps

**Proceed to Lab 2: VPC Peering**

Lab 2 will:
- Use `terraform_remote_state` to reference these resources
- Create VPC peering connection
- Add routes between VPCs
- Test connectivity (will WORK this time!)

**⚠️ Keep infrastructure running - Lab 2 depends on it!**

---

## Terraform Command Cheat Sheet

| Command | Purpose |
|---------|---------|
| `terraform init` | Initialize working directory |
| `terraform validate` | Check syntax |
| `terraform fmt` | Format code |
| `terraform plan` | Preview changes |
| `terraform apply` | Create/update resources |
| `terraform destroy` | Delete all resources |
| `terraform output` | Show output values |
| `terraform state list` | List managed resources |
| `terraform state show <resource>` | Show resource details |
| `terraform refresh` | Sync state with AWS |
| `terraform graph` | Generate dependency graph |

---

## Additional Resources

- [Terraform CLI Documentation](https://www.terraform.io/cli)
- [AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Terraform State Management](https://www.terraform.io/language/state)
- [VPC Peering Guide](https://docs.aws.amazon.com/vpc/latest/peering/)
