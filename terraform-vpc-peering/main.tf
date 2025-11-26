# Terraform VPC Peering Demo
# Creates two VPCs with different CIDR blocks and peers them together

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

# VPC 1 - Production Network
resource "aws_vpc" "vpc_1" {
  cidr_block           = var.vpc_1_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${var.project_name}-vpc-1"
    Environment = "production"
    Project     = var.project_name
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
  }
}

# Subnet in VPC 1
resource "aws_subnet" "vpc_1_subnet" {
  vpc_id                  = aws_vpc.vpc_1.id
  cidr_block              = var.vpc_1_subnet_cidr
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name    = "${var.project_name}-vpc-1-subnet"
    Project = var.project_name
  }
}

# Subnet in VPC 2
resource "aws_subnet" "vpc_2_subnet" {
  vpc_id                  = aws_vpc.vpc_2.id
  cidr_block              = var.vpc_2_subnet_cidr
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name    = "${var.project_name}-vpc-2-subnet"
    Project = var.project_name
  }
}

# Internet Gateway for VPC 1
resource "aws_internet_gateway" "vpc_1_igw" {
  vpc_id = aws_vpc.vpc_1.id

  tags = {
    Name    = "${var.project_name}-vpc-1-igw"
    Project = var.project_name
  }
}

# Internet Gateway for VPC 2
resource "aws_internet_gateway" "vpc_2_igw" {
  vpc_id = aws_vpc.vpc_2.id

  tags = {
    Name    = "${var.project_name}-vpc-2-igw"
    Project = var.project_name
  }
}

# Route Table for VPC 1
resource "aws_route_table" "vpc_1_rt" {
  vpc_id = aws_vpc.vpc_1.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vpc_1_igw.id
  }

  route {
    cidr_block                = var.vpc_2_cidr
    vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
  }

  tags = {
    Name    = "${var.project_name}-vpc-1-rt"
    Project = var.project_name
  }
}

# Route Table for VPC 2
resource "aws_route_table" "vpc_2_rt" {
  vpc_id = aws_vpc.vpc_2.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vpc_2_igw.id
  }

  route {
    cidr_block                = var.vpc_1_cidr
    vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
  }

  tags = {
    Name    = "${var.project_name}-vpc-2-rt"
    Project = var.project_name
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

# VPC Peering Connection
resource "aws_vpc_peering_connection" "peer" {
  vpc_id      = aws_vpc.vpc_1.id
  peer_vpc_id = aws_vpc.vpc_2.id
  auto_accept = true

  tags = {
    Name    = "${var.project_name}-vpc-peering"
    Project = var.project_name
  }
}

# Security Group for VPC 1
resource "aws_security_group" "vpc_1_sg" {
  name        = "${var.project_name}-vpc-1-sg"
  description = "Security group for VPC 1 instances"
  vpc_id      = aws_vpc.vpc_1.id

  # Allow SSH from anywhere (for demo purposes)
  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow ICMP (ping) from VPC 2
  ingress {
    description = "ICMP from VPC 2"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [var.vpc_2_cidr]
  }

  # Allow all traffic from VPC 2
  ingress {
    description = "All traffic from VPC 2"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
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
  }
}

# Security Group for VPC 2
resource "aws_security_group" "vpc_2_sg" {
  name        = "${var.project_name}-vpc-2-sg"
  description = "Security group for VPC 2 instances"
  vpc_id      = aws_vpc.vpc_2.id

  # Allow SSH from anywhere (for demo purposes)
  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow ICMP (ping) from VPC 1
  ingress {
    description = "ICMP from VPC 1"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [var.vpc_1_cidr]
  }

  # Allow all traffic from VPC 1
  ingress {
    description = "All traffic from VPC 1"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
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
  }
}

# Data source for availability zones
data "aws_availability_zones" "available" {
  state = "available"
}
