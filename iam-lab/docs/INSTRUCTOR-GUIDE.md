# Instructor Guide - IAM Roles and Permissions Lab

## 🎓 Teaching Objectives

Students will learn:
- IAM role creation and management
- EC2 instance profiles and how they work
- Permission testing and validation
- Dynamic permission modification
- Principle of least privilege
- AWS CLI usage from EC2 instances

## ⏱️ Time Breakdown

| Activity | Duration | Notes |
|----------|----------|-------|
| Introduction | 5 min | Explain IAM roles vs users |
| Step 1: Create IAM Role | 5 min | Show in console |
| Step 2: Create S3 Bucket | 5 min | Use CloudShell |
| Step 3: Launch EC2 | 5 min | Emphasize instance profile |
| Step 4: Test Permissions | 10 min | Show read works, write fails |
| Step 5: Modify Permissions | 5 min | Add write permissions |
| Step 6: Test EC2 Permissions | 5 min | Show permission boundaries |
| Optional Step 7 | 5 min | Add EC2 permissions |
| Cleanup | 5 min | Important! |
| **Total** | **50 min** | Including discussion |

## 🎯 Key Teaching Points

### 1. IAM Roles vs IAM Users

**IAM Users**:
- Long-term credentials (access keys)
- For people or applications
- Credentials must be managed and rotated

**IAM Roles**:
- Temporary credentials
- For AWS services or federated users
- Credentials automatically rotated
- No long-term secrets to manage

### 2. EC2 Instance Profiles

- Container for an IAM role
- Allows EC2 to assume the role
- Provides temporary credentials via instance metadata
- Credentials automatically rotated every hour

**Show students**:
```bash
# From EC2 instance, show metadata
curl http://169.254.169.254/latest/meta-data/iam/security-credentials/vm-app-role
```

### 3. How Applications Get Credentials

1. Application makes AWS API call
2. AWS SDK checks for credentials in this order:
   - Environment variables
   - Credentials file
   - **Instance metadata (IAM role)** ← This is what we're using
3. SDK retrieves temporary credentials from metadata service
4. SDK uses credentials to sign API request

### 4. Permission Propagation

- IAM changes can take 5-15 seconds to propagate
- This is due to eventual consistency
- In production, plan for this delay

## 🚨 Common Student Issues

### Issue 1: "Bucket name already exists"

**Symptom**: Error when creating S3 bucket

**Cause**: S3 bucket names are globally unique

**Solution**:
```bash
# Use more unique name
aws s3 mb s3://iam-lab-yourname-20241126
# Or add random numbers
aws s3 mb s3://iam-lab-yourname-$RANDOM
```

### Issue 2: "Access Denied" persists after adding permissions

**Symptom**: Still getting access denied after modifying role

**Cause**: IAM changes take time to propagate

**Solution**:
- Wait 10-15 seconds
- Try command again
- Explain eventual consistency

### Issue 3: Can't find IAM role when launching EC2

**Symptom**: Role doesn't appear in dropdown

**Cause**: Role wasn't created with EC2 trust policy

**Solution**:
- Verify role exists in IAM console
- Check trust policy includes EC2 service
- Refresh the EC2 launch page

### Issue 4: Can't connect to EC2 instance

**Symptom**: EC2 Instance Connect fails

**Causes**:
- Instance not fully started
- Status checks not passed
- Security group blocking port 22

**Solutions**:
- Wait for 2/2 status checks
- Verify security group allows SSH (port 22)
- Try regular SSH if Instance Connect fails

### Issue 5: AWS CLI not found on EC2

**Symptom**: `aws: command not found`

**Cause**: Wrong AMI selected (not Amazon Linux 2023)

**Solution**:
- Terminate instance
- Launch new instance with Amazon Linux 2023
- AWS CLI is pre-installed on Amazon Linux

## 📊 Demonstration Flow

### 1. Introduction (5 min)

**Topics to cover**:
- What are IAM roles?
- Why use roles instead of access keys?
- What is an instance profile?
- Real-world use cases

**Demo**:
- Show IAM console
- Explain roles vs users
- Show existing roles (if any)

### 2. Create IAM Role (5 min)

**Walk through**:
1. Navigate to IAM → Roles
2. Click Create role
3. Select EC2 as trusted entity
4. Attach AmazonS3ReadOnlyAccess
5. Name it vm-app-role
6. Show the trust policy (JSON)

**Explain**:
- Trust policy (who can assume)
- Permission policy (what they can do)
- Managed vs inline policies

### 3. Create S3 Bucket (5 min)

**Walk through**:
1. Open CloudShell
2. Create test file
3. Create bucket (show unique naming)
4. Upload file
5. Verify upload

**Explain**:
- S3 bucket naming rules
- AWS CLI basics
- CloudShell convenience

### 4. Launch EC2 Instance (5 min)

**Walk through**:
1. Navigate to EC2
2. Launch instance wizard
3. **Important**: Show IAM instance profile selection
4. Explain what happens behind the scenes

**Explain**:
- Instance profile creation (automatic)
- How credentials are delivered
- Metadata service (169.254.169.254)

### 5. Test Permissions (10 min)

**Walk through**:
1. Connect via EC2 Instance Connect
2. List S3 bucket (works)
3. Download file (works)
4. Try to upload (fails)

**Explain**:
- Why read works
- Why write fails
- Permission boundaries
- Least privilege principle

**Show the error message**:
```
An error occurred (AccessDenied) when calling the PutObject operation
```

### 6. Modify Permissions (5 min)

**Walk through**:
1. Go to IAM → Roles → vm-app-role
2. Add AmazonS3FullAccess
3. Wait 10-15 seconds
4. Try upload again (works!)

**Explain**:
- No need to restart instance
- No need to reconnect
- Permissions update automatically
- Propagation delay

### 7. Test EC2 Permissions (5 min)

**Walk through**:
1. Try to list EC2 instances (fails)
2. Explain why (no EC2 permissions)
3. Optionally add EC2ReadOnlyAccess
4. Try again (works)

**Explain**:
- Permission boundaries
- Explicit deny vs no permission
- Least privilege in action

## 💡 Tips for Success

### Before Class
1. **Test the lab yourself** - Catch any issues
2. **Prepare screenshots** - Show expected outputs
3. **Have backup plan** - If AWS has issues
4. **Review IAM concepts** - Be ready for questions

### During Class
1. **Go slow** - IAM can be confusing
2. **Show, don't just tell** - Live demo is key
3. **Explain the "why"** - Not just the "how"
4. **Encourage questions** - IAM is complex
5. **Monitor progress** - Help struggling students

### After Class
1. **Verify cleanup** - Check for orphaned resources
2. **Collect feedback** - Improve for next time
3. **Answer questions** - Follow up via email/forum

## 🎨 Extension Activities

### Easy
1. Add CloudWatch Logs permissions
2. Test with different S3 permissions
3. Create custom IAM policy

### Medium
1. Use IAM policy conditions
2. Test with multiple roles
3. Implement resource-based policies

### Advanced
1. Cross-account role assumption
2. Use AWS STS for temporary credentials
3. Implement ABAC (Attribute-Based Access Control)

## 📝 Assessment Ideas

### Knowledge Check Questions
1. What is the difference between an IAM role and an IAM user?
2. What is an EC2 instance profile?
3. How do applications on EC2 get AWS credentials?
4. Why is it better to use IAM roles than access keys for EC2?
5. What is the principle of least privilege?

### Hands-On Challenges
1. **Easy**: Add DynamoDB read permissions and test
2. **Medium**: Create a custom IAM policy for specific S3 bucket
3. **Hard**: Set up cross-account role assumption

### Lab Report Requirements
- Screenshots of each major step
- Answers to lab questions
- Explanation of permission boundaries
- Discussion of least privilege principle

## 🔍 Troubleshooting Guide for Instructors

### Student can't create IAM role
- **Check**: IAM permissions
- **Solution**: Verify student has `iam:CreateRole` permission

### Student can't launch EC2 instance
- **Check**: EC2 permissions, VPC configuration
- **Solution**: Verify `ec2:RunInstances` permission

### Permissions not updating
- **Check**: Time elapsed since change
- **Solution**: Wait 15-30 seconds, try again

### Student forgot to clean up
- **Check**: EC2 instances, S3 buckets, IAM roles
- **Solution**: Provide cleanup script or manual steps

## 📊 Success Metrics

Track these to measure effectiveness:
- % of students who complete successfully
- Average time to completion
- Number of support requests
- Student understanding of IAM concepts
- Proper resource cleanup rate

## 🎯 Learning Outcomes Assessment

| Outcome | Assessment Method |
|---------|-------------------|
| Understand IAM roles | Lab questions 1-2 |
| Create and attach roles | Successful lab completion |
| Test permissions | Screenshots of tests |
| Modify permissions | Step 5 completion |
| Apply least privilege | Lab question 6 |

## 📞 Support Resources

If students need help:
1. LAB-INSTRUCTIONS.md (troubleshooting section)
2. AWS IAM documentation
3. Office hours
4. Discussion forum
5. Instructor assistance

## 🎉 Wrap-Up Discussion Points

### Key Takeaways
- IAM roles provide temporary credentials
- Instance profiles attach roles to EC2
- Permissions can be modified without restarting
- Always follow least privilege principle
- Test permissions thoroughly

### Real-World Applications
- Web applications accessing databases
- Data processing pipelines
- Microservices architecture
- CI/CD systems
- Serverless applications

### Best Practices
- Use roles, not access keys
- Start with minimal permissions
- Test permission boundaries
- Monitor and audit role usage
- Regular permission reviews

---

**Questions?** Prepare answers to common IAM questions before class!

**Good luck teaching! 🎓**
