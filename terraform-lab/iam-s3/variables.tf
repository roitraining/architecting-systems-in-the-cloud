# Variables for Lab 3: IAM and S3

variable "aws_region" {
  description = "AWS region (must match Lab 1)"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name for resource tagging"
  type        = string
  default     = "terraform-lab"
}

variable "bucket_suffix" {
  description = "Unique suffix for S3 bucket name (use your name or random string)"
  type        = string
  default     = "test-bucket"
}
