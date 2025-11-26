# VPC Peering with Terraform - Student Lab

**Course**: AWS Cloud Architecture  
**Lab**: Infrastructure as Code with Terraform  
**Time**: 30-40 minutes

---

## 🎯 Objective

Use Terraform to create two VPCs and establish a VPC peering connection between them.

## 📋 Prerequisites

- ✅ AWS Account access
- ✅ AWS CLI configured OR access to AWS CloudShell
- ✅ Terraform installed (or use CloudShell)

---

## 🚀 Lab Steps

### Step 1: Access CloudShell (5 min)

1. Log into AWS Console
2. Click the **CloudShell** icon in top navigation
3. Wait for CloudShell to initialize
4. Verify Terraform is installed:
```bash
terraform version
```

✅ **Checkpoint**: You should see Terraform version 1.x.x

### Step 2: Get the Code (2 min)

```bash
# Clone the repository
git clone <INSTRUCTOR_PROVIDES_URL>
cd terraform-vpc-peering
```

✅ **Checkpoint**: You should see `main.tf`, `variables.tf`, and `outputs.tf`

### Step 3: Review the Configuration (5 min)

```bash
# View the main configuration
cat main.tf

# View variables
cat variables.tf

# View outputs
cat outputs.tf
```

**Questions to consider**:
- What CIDR blocks are used for each VPC?
- What security group rules are configured?
- How is the VPC peering connection created?

### Step 4: Initialize Terraform (2 min)

```bash
terraform init
```

This downloads the AWS provider plugin.

✅ **Checkpoint**: You should see "Terraform has been successfully initialized!"

### Step 5: Plan the Deployment (3 min)

```bash
terraform plan
```

Review the output. You should see:
- 2 VPCs
- 2 Subnets
- 2 Internet Gateways
- 2 Route Tables
- 1 VPC Peering Connection
- 2 Security Groups

✅ **Checkpoint**: Plan shows ~13 resources to be created

### Step 6: Apply the Configuration (5 min)

```bash
terraform apply
```

Type `yes` when prompted.

⏱️ **This takes 2-3 minutes**

✅ **Checkpoint**: You should see "Apply complete! Resources: 13 added"

### Step 7: View Outputs (2 min)

```bash
# View all outputs
terraform output

# View summary
terraform output summary
```

✅ **Checkpoint**: You should see VPC IDs, CIDR blocks, and peering connection ID

### Step 8: Verify in AWS Console (5 min)

1. Go to **VPC Dashboard** in AWS Console
2. Click **Your VPCs** - you should see 2 new VPCs
3. Click **Peering Connections** - you should see 1 active connection
4. Click **Route Tables** - verify routes to peered VPC

✅ **Checkpoint**: All resources visible in console

### Step 9: Test Connectivity (Optional - 10 min)

If time permits, launch EC2 instances to test:

```bash
# Get subnet and security group IDs
terraform output vpc_1_subnet_id
terraform output vpc_1_security_group_id
```

Launch instances in AWS Console using these values, then test ping between them.

### Step 10: Cleanup (5 min)

**IMPORTANT**: Delete all resources to avoid charges!

```bash
terraform destroy
```

Type `yes` when prompted.

✅ **Checkpoint**: You should see "Destroy complete! Resources: 13 destroyed"

---

## 📝 Lab Questions

Answer these for your lab report:

1. What are the CIDR blocks for VPC 1 and VPC 2?
2. Why must VPC CIDR blocks not overlap for peering?
3. What is the ID of the VPC peering connection created?
4. What security group rules allow traffic between VPCs?
5. How does Terraform know the order to create resources?
6. What command shows you what Terraform will do before applying?
7. Where is Terraform state stored by default?
8. What happens if you run `terraform apply` twice?

---

## 🐛 Troubleshooting

| Problem | Solution |
|---------|----------|
| `terraform: command not found` | Use AWS CloudShell (Terraform pre-installed) |
| Permission errors | Verify AWS credentials are configured |
| CIDR overlap error | Check variables.tf for non-overlapping ranges |
| Apply fails | Run `terraform destroy` and try again |

---

## ✅ Submission Checklist

- [ ] Terraform apply completed successfully
- [ ] Screenshot of `terraform output summary`
- [ ] Screenshot of VPCs in AWS Console
- [ ] Screenshot of VPC peering connection (active status)
- [ ] Lab questions answered
- [ ] Resources destroyed (screenshot of destroy output)

---

## 🎓 What You Learned

- ✅ Infrastructure as Code concepts
- ✅ Terraform workflow (init, plan, apply, destroy)
- ✅ VPC creation and configuration
- ✅ VPC peering setup
- ✅ Security group configuration
- ✅ Route table management
- ✅ Terraform state management

---

## 📚 Additional Resources

- Full guide: `README.md`
- [Terraform AWS Provider Docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS VPC Peering Guide](https://docs.aws.amazon.com/vpc/latest/peering/)

---

**Questions?** Ask your instructor or check the README.md file!

**Good luck! 🚀**
