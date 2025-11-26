# Terraform VPC Peering - Quick Reference

## 🚀 Quick Start

```bash
# 1. Navigate to directory
cd terraform-vpc-peering

# 2. Initialize
terraform init

# 3. Plan
terraform plan

# 4. Apply
terraform apply

# 5. View outputs
terraform output

# 6. Cleanup
terraform destroy
```

## 📋 Essential Terraform Commands

| Command | Description |
|---------|-------------|
| `terraform init` | Initialize working directory |
| `terraform plan` | Preview changes |
| `terraform apply` | Create/update resources |
| `terraform destroy` | Delete all resources |
| `terraform output` | Show output values |
| `terraform show` | Show current state |
| `terraform fmt` | Format code |
| `terraform validate` | Validate configuration |
| `terraform state list` | List resources in state |

## 🏗️ What Gets Created

- 2 VPCs (10.1.0.0/16 and 10.2.0.0/16)
- 2 Subnets
- 2 Internet Gateways
- 2 Route Tables (with peering routes)
- 1 VPC Peering Connection
- 2 Security Groups

**Total**: 13 resources

## 📊 Key Outputs

```bash
# Get VPC IDs
terraform output vpc_1_id
terraform output vpc_2_id

# Get peering connection ID
terraform output vpc_peering_connection_id

# Get security group IDs
terraform output vpc_1_security_group_id
terraform output vpc_2_security_group_id

# Get summary
terraform output summary
```

## 🐛 Troubleshooting

**Terraform not found?**
```bash
# Use AWS CloudShell (pre-installed)
```

**Permission errors?**
```bash
# Check AWS credentials
aws sts get-caller-identity
```

**Want to start over?**
```bash
terraform destroy
terraform apply
```

**See what's in state?**
```bash
terraform state list
```

## 📁 File Structure

```
terraform-vpc-peering/
├── main.tf           # Main configuration
├── variables.tf      # Variables
├── outputs.tf        # Outputs
└── README.md         # Full documentation
```

## 🎯 Success Checklist

- [ ] `terraform init` successful
- [ ] `terraform plan` shows 13 resources
- [ ] `terraform apply` completes
- [ ] Outputs show VPC and peering IDs
- [ ] Resources visible in AWS Console
- [ ] `terraform destroy` completes

## 💰 Cost

- **VPCs, Subnets, IGWs**: Free
- **VPC Peering**: Free (same region)
- **Security Groups**: Free

**Total**: $0 (without EC2 instances)

## ⚠️ Remember

Always run `terraform destroy` when done to clean up!

---

**Need more details?** See `README.md` or `STUDENT-HANDOUT.md`
