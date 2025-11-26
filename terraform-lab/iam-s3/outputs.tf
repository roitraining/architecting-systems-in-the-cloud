# Outputs for Lab 3: IAM and S3

output "s3_bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.test_bucket.id
}

output "iam_role_name" {
  description = "Name of the IAM role"
  value       = aws_iam_role.ec2_s3_role.name
}

output "iam_role_arn" {
  description = "ARN of the IAM role"
  value       = aws_iam_role.ec2_s3_role.arn
}

output "instance_profile_name" {
  description = "Name of the instance profile"
  value       = aws_iam_instance_profile.ec2_s3_profile.name
}

output "test_instructions" {
  description = "Instructions for testing IAM and S3 access"
  value = <<-EOT
    
    ========================================
    Lab 3: IAM and S3 Access - Complete!
    ========================================
    
    S3 Bucket Created:
      - Bucket Name: ${aws_s3_bucket.test_bucket.id}
      - Test File: sampledata.txt
    
    IAM Role Created:
      - Role Name: ${aws_iam_role.ec2_s3_role.name}
      - Permissions: S3 Read-Only (initially)
      - Instance Profile: ${aws_iam_instance_profile.ec2_s3_profile.name}
    
    Testing Steps:
    
    Step 1: Test WITHOUT IAM Role (Should Fail)
      1. Connect to VPC 1 instance: ${data.terraform_remote_state.lab1.outputs.vpc_1_instance_id}
      2. Try to list S3 bucket:
         aws s3 ls s3://${aws_s3_bucket.test_bucket.id}/
      3. This should FAIL with "Unable to locate credentials"
    
    Step 2: Attach IAM Role to Instance
      1. Go to EC2 Console
      2. Select instance: ${data.terraform_remote_state.lab1.outputs.vpc_1_instance_id}
      3. Actions → Security → Modify IAM role
      4. Select: ${aws_iam_instance_profile.ec2_s3_profile.name}
      5. Click "Update IAM role"
    
    Step 3: Test WITH IAM Role (Should Work)
      1. Reconnect to the instance (or wait 30 seconds)
      2. List S3 bucket:
         aws s3 ls s3://${aws_s3_bucket.test_bucket.id}/
      3. This should now WORK! ✓
      4. Download the file:
         aws s3 cp s3://${aws_s3_bucket.test_bucket.id}/sampledata.txt .
         cat sampledata.txt
    
    Step 4: Test Write Permissions (Should Fail)
      1. Create a new file:
         echo "New file content" > newfile.txt
      2. Try to upload:
         aws s3 cp newfile.txt s3://${aws_s3_bucket.test_bucket.id}/
      3. This should FAIL - role only has read permissions
    
    Step 5: Add Write Permissions
      1. Go to IAM Console → Roles
      2. Find role: ${aws_iam_role.ec2_s3_role.name}
      3. Click "Add permissions" → "Attach policies"
      4. Search for and attach: AmazonS3FullAccess
      5. Wait 10-15 seconds for propagation
    
    Step 6: Test Write Permissions Again (Should Work)
      1. Try upload again:
         aws s3 cp newfile.txt s3://${aws_s3_bucket.test_bucket.id}/
      2. This should now WORK! ✓
      3. Verify:
         aws s3 ls s3://${aws_s3_bucket.test_bucket.id}/
    
    ========================================
    
    Cleanup:
      Run 'terraform destroy' in each lab directory (reverse order):
      1. cd ../lab3-iam-s3 && terraform destroy
      2. cd ../lab2-vpc-peering && terraform destroy
      3. cd ../lab1-vpc-ec2 && terraform destroy
    
    ========================================
  EOT
}
