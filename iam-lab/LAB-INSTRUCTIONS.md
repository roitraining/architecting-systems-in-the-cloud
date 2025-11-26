# IAM Roles and Permissions Lab

**Course**: AWS Cloud Architecture  
**Lab**: IAM Roles, EC2 Instance Profiles, and S3 Permissions  
**Time**: 30-40 minutes

---

## 🎯 Objective

Learn how to create IAM roles with limited permissions, attach them to EC2 instances, and test permission boundaries. Understand how applications running on EC2 automatically inherit the instance's IAM role permissions.

## 📋 Prerequisites

- AWS Account with appropriate permissions
- Access to AWS Console
- Basic understanding of EC2 and S3

---

## Step 1: Create an IAM Role with Limited Permissions

### 1.1 Navigate to IAM

1. Log into the AWS Console
2. In the search bar, type **IAM** and select **IAM** from the results
3. In the left navigation, click **Roles**
4. Click the **Create role** button

### 1.2 Configure the Role

1. **Select trusted entity type**: Choose **AWS service**
2. **Use case**: Select **EC2** from the list
3. Click **Next**

### 1.3 Add Permissions

1. In the search box, type **S3**
2. Check the box next to **AmazonS3ReadOnlyAccess**
3. Click **Next**

### 1.4 Name and Create the Role

1. **Role name**: `vm-app-role`
2. **Description**: `Role for EC2 instances to access S3 with read-only permissions`
3. Review the settings
4. Click **Create role**

✅ **Checkpoint**: You should see "Role vm-app-role created successfully"

---

## Step 2: Create an S3 Bucket and Upload a File

### 2.1 Open CloudShell

1. In the AWS Console, click the **CloudShell** icon in the top navigation bar
2. Wait for CloudShell to initialize

### 2.2 Create a Test File

```bash
echo "this is some sample data" > sampledata.txt
```

### 2.3 Create an S3 Bucket

```bash
# Replace <yourname> with your name or initials to make it unique
aws s3 mb s3://iam-lab-yourname
```

**Note**: If you get an error that the bucket already exists, try a different name. S3 bucket names must be globally unique across all of AWS.

### 2.4 Upload the File to S3

```bash
# Replace <yourname> with the same name you used above
aws s3 cp sampledata.txt s3://iam-lab-yourname/
```

### 2.5 Verify the Upload

```bash
aws s3 ls s3://iam-lab-yourname/
```

You should see `sampledata.txt` listed.

✅ **Checkpoint**: File successfully uploaded to S3 bucket

---

## Step 3: Launch an EC2 Instance with the IAM Role

### 3.1 Navigate to EC2

1. In the AWS Console search bar, type **EC2** and select **EC2**
2. Click **Instances** in the left navigation
3. Click the **Launch instances** button

### 3.2 Configure the Instance

1. **Name**: `iam-lab-vm`

2. **Application and OS Images (Amazon Machine Image)**:
   - Select **Amazon Linux 2023** (should be selected by default)

3. **Instance type**:
   - Select **t2.micro** (Free tier eligible)

4. **Key pair (login)**:
   - Select **Proceed without a key pair** (we'll use EC2 Instance Connect)

5. **Network settings**:
   - Leave defaults (will use default VPC)
   - Ensure **Auto-assign public IP** is **Enabled**

6. **Advanced details** (expand this section):
   - Scroll down to **IAM instance profile**
   - Select **vm-app-role** from the dropdown

7. Leave all other settings at their defaults

8. Click **Launch instance**

### 3.3 Wait for Instance to Start

1. Click **View all instances**
2. Wait until the **Instance state** shows **Running** (takes 1-2 minutes)
3. Wait until **Status check** shows **2/2 checks passed**

✅ **Checkpoint**: Instance is running with IAM role attached

---

## Step 4: Connect to the Instance and Test Permissions

### 4.1 Connect to the Instance

1. Select your instance by checking the box next to it
2. Click the **Connect** button at the top
3. Click the **EC2 Instance Connect** tab
4. Click **Connect**

A new browser tab will open with a terminal session.

### 4.2 Test Read Permissions

From the EC2 terminal session, list the contents of your S3 bucket:

```bash
# Replace <yourname> with your bucket name
aws s3 ls s3://iam-lab-yourname/
```

✅ **You should see the sampledata.txt file listed.**

This works because the IAM role has **AmazonS3ReadOnlyAccess** permissions.

### 4.3 Download the File

Try downloading the file from S3 to the EC2 instance:

```bash
# Replace <yourname> with your bucket name
aws s3 cp s3://iam-lab-yourname/sampledata.txt .
```

✅ **The file should download successfully.**

### 4.4 Verify the Downloaded File

```bash
ls
cat sampledata.txt
```

You should see the content: "this is some sample data"

### 4.5 Test Write Permissions (Should Fail)

Create a new file and try to upload it to S3:

```bash
echo "This is the new file" > newfile.txt
aws s3 cp newfile.txt s3://iam-lab-yourname/
```

❌ **You should get an "Access Denied" error.**

This is expected! The IAM role only has **read-only** permissions. It cannot write to S3.

✅ **Checkpoint**: Read permissions work, write permissions are denied

**Keep the terminal session open** - you'll need it for the next step.

---

## Step 5: Modify the IAM Role Permissions

### 5.1 Navigate to IAM

1. Go back to the AWS Console (keep the EC2 terminal tab open)
2. Navigate to **IAM** → **Roles**
3. Search for and click on **vm-app-role**

### 5.2 Add Write Permissions

1. Click the **Permissions** tab (if not already selected)
2. Click **Add permissions** → **Attach policies**
3. In the search box, type **S3**
4. Check the box next to **AmazonS3FullAccess**
5. Click **Add permissions**

✅ **Checkpoint**: Role now has both read and write permissions

### 5.3 Test Write Permissions Again

1. Switch back to the EC2 terminal tab
2. Try uploading the file again:

```bash
aws s3 cp newfile.txt s3://iam-lab-yourname/
```

✅ **This time it should work!**

**Note**: If you still get a permission error, wait 10-15 seconds and try again. IAM permission changes can take a few seconds to propagate.

### 5.4 Verify the Upload

```bash
aws s3 ls s3://iam-lab-yourname/
```

You should now see both `sampledata.txt` and `newfile.txt`.

✅ **Checkpoint**: Write permissions now work

---

## Step 6: Test EC2 Permissions (Should Fail)

### 6.1 Try Listing EC2 Instances

From the EC2 terminal, try to list all EC2 instances:

```bash
aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId,State.Name,InstanceType]' --output table
```

❌ **You should get an "UnauthorizedOperation" error.**

This is expected! The IAM role only has S3 permissions. It has no EC2 permissions.

✅ **Checkpoint**: EC2 permissions are correctly denied

---

## Optional Step 7: Add EC2 Read Permissions

### 7.1 Add EC2 Read-Only Policy

1. Go back to the AWS Console
2. Navigate to **IAM** → **Roles** → **vm-app-role**
3. Click **Add permissions** → **Attach policies**
4. Search for **EC2ReadOnly**
5. Check the box next to **AmazonEC2ReadOnlyAccess**
6. Click **Add permissions**

### 7.2 Test EC2 Permissions Again

1. Switch back to the EC2 terminal
2. Wait 10-15 seconds for permissions to propagate
3. Try the command again:

```bash
aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId,State.Name,InstanceType]' --output table
```

✅ **This time it should work!** You should see a table listing your EC2 instance(s).

---

## Step 8: Cleanup

### 8.1 Terminate the EC2 Instance

1. Go to **EC2** → **Instances**
2. Select the **iam-lab-vm** instance
3. Click **Instance state** → **Terminate instance**
4. Click **Terminate** to confirm

### 8.2 Delete the S3 Bucket

From CloudShell:

```bash
# Replace <yourname> with your bucket name
aws s3 rm s3://iam-lab-yourname/ --recursive
aws s3 rb s3://iam-lab-yourname/
```

### 8.3 Delete the IAM Role

1. Go to **IAM** → **Roles**
2. Search for **vm-app-role**
3. Select the role
4. Click **Delete**
5. Type the role name to confirm
6. Click **Delete**

✅ **Checkpoint**: All resources cleaned up

---

## 📝 Lab Questions

Answer these for your lab report:

1. What is an IAM role and how is it different from an IAM user?
2. What is an EC2 instance profile?
3. Why did the write operation fail initially?
4. How do applications running on EC2 get AWS credentials?
5. How long did it take for permission changes to take effect?
6. What is the principle of least privilege and how does this lab demonstrate it?
7. Can you change an instance's IAM role without stopping the instance?

---

## 🎓 What You Learned

- ✅ Creating IAM roles with specific permissions
- ✅ Attaching IAM roles to EC2 instances
- ✅ How EC2 instances automatically inherit role permissions
- ✅ Testing permission boundaries
- ✅ Modifying IAM role permissions dynamically
- ✅ The principle of least privilege
- ✅ AWS CLI usage from EC2 instances

---

## 🔑 Key Concepts

### IAM Role
A set of permissions that can be assumed by AWS services (like EC2) or users. Roles don't have permanent credentials.

### EC2 Instance Profile
A container for an IAM role that allows EC2 instances to assume that role. When you attach a role to an EC2 instance, AWS creates an instance profile automatically.

### Temporary Credentials
When an EC2 instance has an IAM role, AWS automatically provides temporary security credentials that are rotated automatically.

### Principle of Least Privilege
Grant only the permissions necessary to perform a task. Start with minimal permissions and add more as needed.

---

## 🐛 Troubleshooting

| Problem | Solution |
|---------|----------|
| Bucket name already exists | Try a different, more unique name |
| Permission denied after adding policy | Wait 10-15 seconds and try again |
| Can't connect to EC2 instance | Ensure instance is running and status checks passed |
| AWS CLI not found on EC2 | Amazon Linux 2023 has AWS CLI pre-installed |

---

## ✅ Submission Checklist

- [ ] IAM role created with correct permissions
- [ ] S3 bucket created and file uploaded
- [ ] EC2 instance launched with IAM role
- [ ] Successfully tested read permissions
- [ ] Write operation initially denied (screenshot)
- [ ] Write operation succeeded after permission change (screenshot)
- [ ] EC2 list operation denied (screenshot)
- [ ] Lab questions answered
- [ ] All resources cleaned up

---

**Questions?** Ask your instructor!

**Good luck! 🚀**
