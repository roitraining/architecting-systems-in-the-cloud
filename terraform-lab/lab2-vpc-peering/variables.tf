# Variables for Lab 2: VPC Peering

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
