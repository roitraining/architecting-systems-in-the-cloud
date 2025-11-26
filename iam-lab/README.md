# IAM Roles and Permissions Lab

Hands-on lab teaching AWS IAM roles, EC2 instance profiles, and permission management.

## 🎯 Overview

This lab teaches students how to:
- Create IAM roles with specific permissions
- Attach IAM roles to EC2 instances
- Test permission boundaries
- Modify permissions dynamically
- Understand the principle of least privilege

## 📚 Lab Materials

- **LAB-INSTRUCTIONS.md** - Step-by-step student instructions
- **INSTRUCTOR-GUIDE.md** - Teaching guide with solutions
- **QUICK-REFERENCE.md** - Command cheat sheet
- **README.md** - This file

## ⏱️ Time Required

- **Setup**: 10 minutes
- **Testing**: 15 minutes
- **Modifications**: 10 minutes
- **Cleanup**: 5 minutes
- **Total**: 40 minutes

## 🏗️ What Students Will Create

1. **IAM Role** (`vm-app-role`)
   - Initially: S3 read-only access
   - Modified: S3 full access
   - Optional: EC2 read-only access

2. **S3 Bucket** (`iam-lab-yourname`)
   - Contains test files
   - Used to test permissions

3. **EC2 Instance** (`iam-lab-vm`)
   - Amazon Linux 2023
   - t2.micro (free tier)
   - Attached IAM role

## 🎓 Learning Objectives

Students will learn:
- ✅ IAM role creation and management
- ✅ EC2 instance profiles
- ✅ Permission testing and validation
- ✅ Dynamic permission modification
- ✅ Principle of least privilege
- ✅ AWS CLI usage from EC2
- ✅ Temporary security credentials

## 💰 Cost Information

- **IAM Roles**: Free
- **S3 Bucket**: Free (minimal storage)
- **EC2 t2.micro**: Free tier eligible (750 hours/month)
- **Data Transfer**: Minimal (< $0.01)

**Total Lab Cost**: $0 (within free tier)

## 🚀 Quick Start

### For Students
1. Open `LAB-INSTRUCTIONS.md`
2. Follow steps 1-8
3. Answer lab questions
4. Clean up resources

### For Instructors
1. Review `INSTRUCTOR-GUIDE.md`
2. Test the lab yourself
3. Prepare for common issues
4. Monitor student progress

## 📋 Prerequisites

- AWS Account
- IAM permissions to:
  - Create IAM roles
  - Launch EC2 instances
  - Create S3 buckets
- Access to AWS Console
- Basic AWS knowledge

## 🔑 Key Concepts Taught

### IAM Roles
- Service roles vs user roles
- Trust policies
- Permission policies
- Role assumption

### EC2 Instance Profiles
- Automatic credential management
- Temporary security credentials
- Credential rotation

### Permission Management
- Least privilege principle
- Permission testing
- Dynamic permission changes
- Permission propagation time

## 🎯 Success Criteria

Students successfully complete the lab when they:
- ✅ Create IAM role with correct permissions
- ✅ Launch EC2 instance with role attached
- ✅ Successfully test read permissions
- ✅ Verify write permissions are denied
- ✅ Add write permissions to role
- ✅ Verify write permissions now work
- ✅ Understand permission boundaries
- ✅ Clean up all resources

## 🐛 Common Issues

### Issue 1: Bucket Name Already Exists
**Solution**: Use a more unique name (add numbers or date)

### Issue 2: Permissions Don't Update Immediately
**Solution**: Wait 10-15 seconds for IAM changes to propagate

### Issue 3: Can't Connect to EC2 Instance
**Solution**: Ensure instance is running and status checks passed

### Issue 4: AWS CLI Not Working
**Solution**: Amazon Linux 2023 has AWS CLI pre-installed

## 📊 Lab Flow

```
Create IAM Role (S3 Read-Only)
         ↓
Create S3 Bucket & Upload File
         ↓
Launch EC2 Instance with Role
         ↓
Test Read Permissions (✓ Works)
         ↓
Test Write Permissions (✗ Denied)
         ↓
Add S3 Write Permissions to Role
         ↓
Test Write Permissions (✓ Works)
         ↓
Test EC2 Permissions (✗ Denied)
         ↓
Optional: Add EC2 Read Permissions
         ↓
Cleanup All Resources
```

## 🎨 Customization Ideas

### Easy Modifications
- Use different S3 permissions (e.g., specific bucket access)
- Add CloudWatch Logs permissions
- Test DynamoDB permissions

### Medium Modifications
- Create custom IAM policies
- Use multiple IAM roles
- Test cross-account access

### Advanced Modifications
- Implement IAM policy conditions
- Use session policies
- Test with AWS STS

## 📚 Additional Resources

- [AWS IAM Documentation](https://docs.aws.amazon.com/iam/)
- [EC2 Instance Profiles](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_use_switch-role-ec2_instance-profiles.html)
- [IAM Best Practices](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html)

## ✅ Checklist for Instructors

Before class:
- [ ] Test the lab yourself
- [ ] Verify students have necessary IAM permissions
- [ ] Prepare for common issues
- [ ] Review IAM concepts

During class:
- [ ] Demonstrate IAM role creation
- [ ] Explain instance profiles
- [ ] Monitor student progress
- [ ] Help with troubleshooting

After class:
- [ ] Verify all students cleaned up resources
- [ ] Collect feedback
- [ ] Update materials if needed

---

**Ready to start?** Open `LAB-INSTRUCTIONS.md` and begin!
