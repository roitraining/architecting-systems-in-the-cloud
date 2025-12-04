# Lab 1: VPC and EC2 Setup
# Creates two isolated VPCs with EC2 instances
# Students will test connectivity and see that instances CANNOT communicate

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

# Data source for availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

# Data source for latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# VPC 1 - Production Network
resource "aws_vpc" "vpc_1" {
  cidr_block           = var.vpc_1_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${var.project_name}-vpc-1"
    Environment = "production"
    Project     = var.project_name
    Lab         = "lab1-vpc-ec2"
  }
}

# VPC 2 - Development Network
resource "aws_vpc" "vpc_2" {
  cidr_block           = var.vpc_2_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${var.project_name}-vpc-2"
    Environment = "development"
    Project     = var.project_name
    Lab         = "lab1-vpc-ec2"
  }
}

# Subnet in VPC 1
resource "aws_subnet" "vpc_1_subnet" {
  vpc_id                  = aws_vpc.vpc_1.id
  cidr_block              = var.vpc_1_subnet_cidr
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = false

  tags = {
    Name    = "${var.project_name}-vpc-1-subnet"
    Project = var.project_name
    Lab     = "lab1-vpc-ec2"
  }
}

# Subnet in VPC 2
resource "aws_subnet" "vpc_2_subnet" {
  vpc_id                  = aws_vpc.vpc_2.id
  cidr_block              = var.vpc_2_subnet_cidr
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = false

  tags = {
    Name    = "${var.project_name}-vpc-2-subnet"
    Project = var.project_name
    Lab     = "lab1-vpc-ec2"
  }
}

# Route Table for VPC 1 (no internet gateway)
resource "aws_route_table" "vpc_1_rt" {
  vpc_id = aws_vpc.vpc_1.id

  tags = {
    Name    = "${var.project_name}-vpc-1-rt"
    Project = var.project_name
    Lab     = "lab1-vpc-ec2"
  }
}

# Route Table for VPC 2 (no internet gateway)
resource "aws_route_table" "vpc_2_rt" {
  vpc_id = aws_vpc.vpc_2.id

  tags = {
    Name    = "${var.project_name}-vpc-2-rt"
    Project = var.project_name
    Lab     = "lab1-vpc-ec2"
  }
}

# Route Table Association for VPC 1
resource "aws_route_table_association" "vpc_1_rta" {
  subnet_id      = aws_subnet.vpc_1_subnet.id
  route_table_id = aws_route_table.vpc_1_rt.id
}

# Route Table Association for VPC 2
resource "aws_route_table_association" "vpc_2_rta" {
  subnet_id      = aws_subnet.vpc_2_subnet.id
  route_table_id = aws_route_table.vpc_2_rt.id
}

# IAM Role for SSM
resource "aws_iam_role" "ssm_role" {
  name = "${var.project_name}-ssm-role"

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
    Name    = "${var.project_name}-ssm-role"
    Project = var.project_name
    Lab     = "lab1-vpc-ec2"
  }
}

# Attach SSM managed policy to role
resource "aws_iam_role_policy_attachment" "ssm_policy" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Instance profile for EC2
resource "aws_iam_instance_profile" "ssm_profile" {
  name = "${var.project_name}-ssm-profile"
  role = aws_iam_role.ssm_role.name

  tags = {
    Name    = "${var.project_name}-ssm-profile"
    Project = var.project_name
    Lab     = "lab1-vpc-ec2"
  }
}

# Security Group for VPC 1
resource "aws_security_group" "vpc_1_sg" {
  name        = "${var.project_name}-vpc-1-sg"
  description = "Security group for VPC 1 instances"
  vpc_id      = aws_vpc.vpc_1.id

  # Allow SSH from anywhere
  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow ICMP (ping) from VPC 2 - will be used in Lab 2
  ingress {
    description = "ICMP from VPC 2"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [var.vpc_2_cidr]
  }

  # Allow all outbound traffic
  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.project_name}-vpc-1-sg"
    Project = var.project_name
    Lab     = "lab1-vpc-ec2"
  }
}

# Security Group for VPC 2
resource "aws_security_group" "vpc_2_sg" {
  name        = "${var.project_name}-vpc-2-sg"
  description = "Security group for VPC 2 instances"
  vpc_id      = aws_vpc.vpc_2.id

  # Allow SSH from anywhere
  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow ICMP (ping) from VPC 1 - will be used in Lab 2
  ingress {
    description = "ICMP from VPC 1"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [var.vpc_1_cidr]
  }

  # Allow all outbound traffic
  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.project_name}-vpc-2-sg"
    Project = var.project_name
    Lab     = "lab1-vpc-ec2"
  }
}

# EC2 Instance in VPC 1
resource "aws_instance" "vpc_1_instance" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.vpc_1_subnet.id
  vpc_security_group_ids = [aws_security_group.vpc_1_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ssm_profile.name

  # User data to install ping utility
  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y iputils
              EOF

  tags = {
    Name    = "${var.project_name}-vpc-1-instance"
    Project = var.project_name
    Lab     = "lab1-vpc-ec2"
  }
}

# EC2 Instance in VPC 2
resource "aws_instance" "vpc_2_instance" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.vpc_2_subnet.id
  vpc_security_group_ids = [aws_security_group.vpc_2_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ssm_profile.name

  # User data to install ping utility
  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y iputils
              EOF

  tags = {
    Name    = "${var.project_name}-vpc-2-instance"
    Project = var.project_name
    Lab     = "lab1-vpc-ec2"
  }
}
