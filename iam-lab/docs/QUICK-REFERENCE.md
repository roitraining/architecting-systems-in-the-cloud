# IAM Lab - Quick Reference

## 🚀 Quick Commands

### Step 2: S3 Bucket Setup
```bash
# Create test file
echo "this is some sample data" > sampledata.txt

# Create bucket (replace <yourname>)
aws s3 mb s3://iam-lab-yourname

# Upload file
aws s3 cp sampledata.txt s3://iam-lab-yourname/

# List bucket
aws s3 ls s3://iam-lab-yourname/
```

### Step 4: Test Permissions (from EC2)
```bash
# List bucket (should work)
aws s3 ls s3://iam-lab-yourname/

# Download file (should work)
aws s3 cp s3://iam-lab-yourname/sampledata.txt .

# View file
cat sampledata.txt

# Create new file
echo "This is the new file" > newfile.txt

# Try to upload (should fail initially)
aws s3 cp newfile.txt s3://iam-lab-yourname/
```

### Step 5: After Adding Permissions
```bash
# Try upload again (should work now)
aws s3 cp newfile.txt s3://iam-lab-yourname/

# Verify
aws s3 ls s3://iam-lab-yourname/
```

### Step 6: Test EC2 Permissions
```bash
# Try to list instances (should fail)
aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId,State.Name,InstanceType]' --output table
```

### Step 7: After Adding EC2 Permissions
```bash
# Try again (should work)
aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId,State.Name,InstanceType]' --output table
```

### Cleanup
```bash
# Delete bucket contents and bucket
aws s3 rm s3://iam-lab-yourname/ --recursive
aws s3 rb s3://iam-lab-yourname/
```

## 📋 IAM Policies Used

| Policy | Purpose | Permissions |
|--------|---------|-------------|
| AmazonS3ReadOnlyAccess | Read S3 objects | List, Get |
| AmazonS3FullAccess | Read/Write S3 | All S3 operations |
| AmazonEC2ReadOnlyAccess | View EC2 resources | Describe operations |

## 🎯 Expected Results

### Initial State (S3 Read-Only)
- ✅ List bucket contents
- ✅ Download files
- ❌ Upload files
- ❌ List EC2 instances

### After Adding S3 Full Access
- ✅ List bucket contents
- ✅ Download files
- ✅ Upload files
- ❌ List EC2 instances

### After Adding EC2 Read-Only
- ✅ List bucket contents
- ✅ Download files
- ✅ Upload files
- ✅ List EC2 instances

## 🐛 Quick Troubleshooting

| Problem | Solution |
|---------|----------|
| Bucket name exists | Use more unique name |
| Permission denied after adding policy | Wait 10-15 seconds |
| Can't connect to EC2 | Wait for status checks (2/2) |
| AWS CLI not found | Use Amazon Linux 2023 AMI |

## 🔑 Key Concepts

**IAM Role**: Set of permissions that can be assumed by AWS services

**Instance Profile**: Container that passes IAM role to EC2 instance

**Temporary Credentials**: Automatically rotated credentials provided to EC2

**Least Privilege**: Grant only permissions needed for the task

## ⏱️ Time Estimates

- Create IAM Role: 3 min
- Create S3 Bucket: 2 min
- Launch EC2: 5 min
- Test Permissions: 5 min
- Modify Permissions: 3 min
- Test EC2 Permissions: 2 min
- Cleanup: 3 min
- **Total**: ~25 minutes

## ✅ Checklist

- [ ] IAM role created
- [ ] S3 bucket created
- [ ] File uploaded to S3
- [ ] EC2 instance launched with role
- [ ] Read permissions tested (works)
- [ ] Write permissions tested (fails)
- [ ] S3 Full Access added
- [ ] Write permissions tested (works)
- [ ] EC2 permissions tested (fails)
- [ ] Optional: EC2 Read-Only added
- [ ] All resources cleaned up

## 💰 Cost

- IAM Roles: Free
- S3 Bucket: Free (minimal storage)
- EC2 t2.micro: Free tier eligible
- **Total**: $0 (within free tier)

---

**Need more details?** See `LAB-INSTRUCTIONS.md`
