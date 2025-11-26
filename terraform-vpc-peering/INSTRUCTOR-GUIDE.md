# Instructor Guide - Terraform VPC Peering Lab

## 🎓 Teaching Objectives

Students will learn:
- Infrastructure as Code (IaC) concepts
- Terraform workflow and commands
- VPC creation and configuration
- VPC peering concepts and setup
- Security group configuration
- Route table management
- Terraform state management

## ⏱️ Time Required

- **Setup**: 5 minutes
- **Initialization & Planning**: 5 minutes
- **Deployment**: 5 minutes
- **Verification**: 5 minutes
- **Optional Testing**: 10 minutes
- **Cleanup**: 5 minutes
- **Total**: 30-40 minutes

## 📝 Pre-Class Setup

### Option 1: Git Repository (Recommended)
1. Push the terraform-vpc-peering directory to your Git repository
2. Ensure repository is public or students have access
3. Provide students with the clone URL

### Option 2: ZIP File Distribution
1. Create a ZIP file of the `terraform-vpc-peering` directory
2. Upload to a shared location (S3, Google Drive, etc.)
3. Provide students with download link

### Option 3: CloudShell Upload
1. Students can upload files directly to CloudShell
2. Provide ZIP file for upload

## 🎯 Key Teaching Points

### 1. Infrastructure as Code Benefits
- **Repeatability**: Same code = same infrastructure
- **Version Control**: Track changes over time
- **Documentation**: Code documents the infrastructure
- **Automation**: No manual clicking in console

### 2. Terraform Workflow
- **init**: Download providers and modules
- **plan**: Preview changes before applying
- **apply**: Create/update infrastructure
- **destroy**: Clean up resources

### 3. VPC Peering Concepts
- **CIDR blocks must not overlap**
- **Peering is not transitive** (A↔B, B↔C doesn't mean A↔C)
- **Route tables must be updated** on both sides
- **Security groups must allow traffic** from peered VPC

### 4. Terraform State
- **State file tracks resources**: terraform.tfstate
- **Don't edit state manually**: Use terraform commands
- **State is sensitive**: Contains resource IDs and metadata
- **Remote state for teams**: Use S3 + DynamoDB for locking

## 🚨 Common Student Issues

### Issue 1: Terraform Not Found
**Symptom**: `terraform: command not found`

**Solution**: Use AWS CloudShell (Terraform pre-installed)
```bash
# Verify installation
terraform version
```

### Issue 2: AWS Credentials Not Configured
**Symptom**: "No valid credential sources found"

**Solution**: CloudShell has credentials pre-configured
```bash
# Verify credentials
aws sts get-caller-identity
```

### Issue 3: CIDR Block Overlap
**Symptom**: "CIDR blocks overlap" error

**Solution**: Ensure VPCs use different ranges
- VPC 1: 10.1.0.0/16
- VPC 2: 10.2.0.0/16

### Issue 4: Permission Errors
**Symptom**: "User is not authorized to perform..."

**Solution**: Verify IAM permissions include:
- `ec2:*`
- `vpc:*`

### Issue 5: Forgot to Destroy
**Symptom**: Resources still exist after lab

**Solution**: Run cleanup script
```bash
terraform destroy -auto-approve
```

## 📊 Demonstration Flow

### 1. Introduction (5 min)
- Explain Infrastructure as Code
- Show manual VPC creation vs Terraform
- Discuss benefits of IaC

### 2. Code Walkthrough (10 min)
- Open `main.tf` and explain structure
- Show resource blocks (VPC, subnet, etc.)
- Explain dependencies (implicit and explicit)
- Show `variables.tf` for customization
- Show `outputs.tf` for retrieving values

### 3. Live Demo (10 min)
- Run `terraform init` - explain what happens
- Run `terraform plan` - review output
- Run `terraform apply` - watch resources create
- Run `terraform output` - show results
- Open AWS Console - verify resources

### 4. Student Practice (20 min)
- Students follow STUDENT-HANDOUT.md
- Circulate to help with issues
- Encourage exploration of Terraform commands

### 5. Verification (5 min)
- Students show outputs
- Verify in AWS Console
- Discuss what was created

### 6. Cleanup (5 min)
- Demonstrate `terraform destroy`
- Verify in console that resources are deleted
- Emphasize importance of cleanup

## 🔍 Assessment Ideas

### Knowledge Check Questions
1. What is Infrastructure as Code?
2. What does `terraform plan` do?
3. Why must VPC CIDR blocks not overlap?
4. What file stores Terraform state?
5. How does Terraform determine resource creation order?

### Hands-On Challenges
1. **Easy**: Change VPC CIDR blocks and redeploy
2. **Medium**: Add a third subnet to VPC 1
3. **Hard**: Add a NAT Gateway to VPC 1

### Extension Activities
1. Modify security groups to allow only specific ports
2. Add tags to all resources
3. Create a second peering connection
4. Add EC2 instances to test connectivity
5. Implement remote state with S3

## 📋 Instructor Checklist

### Before Class
- [ ] Test the Terraform configuration yourself
- [ ] Verify all students have AWS accounts
- [ ] Confirm students have necessary IAM permissions
- [ ] Prepare the repository or ZIP file
- [ ] Test CloudShell access in your region
- [ ] Review Terraform documentation

### During Class
- [ ] Share the repository/ZIP link
- [ ] Demonstrate each step before students try
- [ ] Monitor student progress
- [ ] Help troubleshoot issues
- [ ] Verify all students successfully deploy
- [ ] Ensure all students destroy resources

### After Class
- [ ] Verify all students destroyed their resources
- [ ] Check for any orphaned resources
- [ ] Collect feedback on the exercise
- [ ] Update materials based on feedback

## 💡 Tips for Success

1. **Use CloudShell**: Eliminates installation issues
2. **Show Console Too**: Display AWS Console alongside Terraform
3. **Emphasize Plan**: Teach students to always review plan first
4. **Explain State**: Help students understand state management
5. **Practice Cleanup**: Make destroy part of the grade
6. **Encourage Exploration**: Let students modify and experiment

## 🎨 Customization Ideas

### For Beginners
- Start with just VPCs (no peering)
- Add peering in a second lab
- Provide more detailed comments in code

### For Advanced Students
- Add EC2 instances automatically
- Implement modules for reusability
- Add remote state configuration
- Implement workspaces for environments

## 📊 Expected Outcomes

### Successful Completion
Students should be able to:
- ✅ Explain Infrastructure as Code benefits
- ✅ Use Terraform init, plan, apply, destroy
- ✅ Create VPCs with Terraform
- ✅ Establish VPC peering
- ✅ Configure security groups and route tables
- ✅ Read and modify Terraform code
- ✅ Troubleshoot common Terraform errors

### Common Mistakes
- Forgetting to run `terraform init`
- Not reviewing `terraform plan` output
- Forgetting to destroy resources
- Editing state file manually
- Not understanding resource dependencies

## 🔗 Additional Resources for Students

- [Terraform Documentation](https://www.terraform.io/docs)
- [AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Terraform Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/)
- [AWS VPC Peering Guide](https://docs.aws.amazon.com/vpc/latest/peering/)

## 📞 Support Resources

If students encounter issues outside of class:
1. README.md (comprehensive guide)
2. TROUBLESHOOTING section in README
3. Terraform documentation
4. AWS documentation
5. Office hours
6. Course discussion board

## 🎉 Success Metrics

Track these to measure effectiveness:
- % of students who successfully deploy
- Average time to complete lab
- Number of support requests
- Student satisfaction scores
- Learning objective achievement
- % of students who properly clean up

## 🔮 Future Enhancements

Possible additions for future versions:
- Add EC2 instances with user data
- Implement Terraform modules
- Add remote state configuration
- Create multi-region peering
- Add VPC endpoints
- Implement Network ACLs
- Add VPN gateway
- Create transit gateway example

## 📝 Grading Rubric (Suggested)

| Criteria | Points | Description |
|----------|--------|-------------|
| Terraform Init | 10 | Successfully initialized Terraform |
| Terraform Plan | 10 | Reviewed plan output |
| Terraform Apply | 20 | Successfully deployed resources |
| Verification | 20 | Verified resources in AWS Console |
| Lab Questions | 20 | Answered all questions correctly |
| Cleanup | 20 | Destroyed all resources |
| **Total** | **100** | |

## 🎯 Learning Outcomes Mapping

| Objective | Activity | Assessment |
|-----------|----------|------------|
| Understand IaC | Lecture + Demo | Lab questions 1-2 |
| Use Terraform | Hands-on lab | Successful deployment |
| Configure VPCs | Code review + Lab | Console verification |
| Implement Peering | Hands-on lab | Peering connection active |
| Manage State | Discussion + Lab | Lab questions 4-5 |

---

**Questions or Issues?** Contact [your contact info]

**Good luck teaching! 🎓**
