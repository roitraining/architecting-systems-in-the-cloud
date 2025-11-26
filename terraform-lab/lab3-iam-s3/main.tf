# Lab 3: IAM Roles and S3 Access
# Adds IAM role and S3 bucket to test permissions
# Students will attach the role to EC2 and test S3 access

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Data source to get Lab 1 outputs
data "terraform_remote_state" "lab1" {
  backend = "local"

  config = {
    path = "../lab1-vpc-ec2/terraform.tfstate"
  }
}

# S3 Bucket for testing
resource "aws_s3_bucket" "test_bucket" {
  bucket = "${var.project_name}-${var.bucket_suffix}"

  tags = {
    Name    = "${var.project_name}-test-bucket"
    Project = var.project_name
    Lab     = "lab3-iam-s3"
  }
}

# Upload a test file to S3
resource "aws_s3_object" "test_file" {
  bucket  = aws_s3_bucket.test_bucket.id
  key     = "sampledata.txt"
  content = "This is some sample data for testing S3 access"

  tags = {
    Project = var.project_name
    Lab     = "lab3-iam-s3"
  }
}

# IAM Role for EC2 to access S3 (Read-Only initially)
resource "aws_iam_role" "ec2_s3_role" {
  name = "${var.project_name}-ec2-s3-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name    = "${var.project_name}-ec2-s3-role"
    Project = var.project_name
    Lab     = "lab3-iam-s3"
  }
}

# Attach S3 Read-Only policy to the role
resource "aws_iam_role_policy_attachment" "s3_read_only" {
  role       = aws_iam_role.ec2_s3_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

# Create instance profile for the role
resource "aws_iam_instance_profile" "ec2_s3_profile" {
  name = "${var.project_name}-ec2-s3-profile"
  role = aws_iam_role.ec2_s3_role.name

  tags = {
    Name    = "${var.project_name}-ec2-s3-profile"
    Project = var.project_name
    Lab     = "lab3-iam-s3"
  }
}
