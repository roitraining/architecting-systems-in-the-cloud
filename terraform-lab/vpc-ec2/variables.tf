# Variables for Lab 1: VPC and EC2 Setup

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name for resource tagging"
  type        = string
  default     = "terraform-lab"
}

variable "vpc_1_cidr" {
  description = "CIDR block for VPC 1"
  type        = string
  default     = "10.1.0.0/16"
}

variable "vpc_2_cidr" {
  description = "CIDR block for VPC 2"
  type        = string
  default     = "10.2.0.0/16"
}

variable "vpc_1_subnet_cidr" {
  description = "CIDR block for VPC 1 subnet"
  type        = string
  default     = "10.1.1.0/24"
}

variable "vpc_2_subnet_cidr" {
  description = "CIDR block for VPC 2 subnet"
  type        = string
  default     = "10.2.1.0/24"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}
