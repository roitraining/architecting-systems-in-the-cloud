# Lab 2: VPC Peering
# Adds VPC peering connection between the two VPCs created in Lab 1
# Students will see connectivity established after this lab

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

# VPC Peering Connection
resource "aws_vpc_peering_connection" "peer" {
  vpc_id      = data.terraform_remote_state.lab1.outputs.vpc_1_id
  peer_vpc_id = data.terraform_remote_state.lab1.outputs.vpc_2_id
  auto_accept = true

  tags = {
    Name    = "${var.project_name}-vpc-peering"
    Project = var.project_name
    Lab     = "lab2-vpc-peering"
  }
}

# Add route to VPC 1 route table for VPC 2 CIDR
resource "aws_route" "vpc_1_to_vpc_2" {
  route_table_id            = data.terraform_remote_state.lab1.outputs.vpc_1_route_table_id
  destination_cidr_block    = data.terraform_remote_state.lab1.outputs.vpc_2_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
}

# Add route to VPC 2 route table for VPC 1 CIDR
resource "aws_route" "vpc_2_to_vpc_1" {
  route_table_id            = data.terraform_remote_state.lab1.outputs.vpc_2_route_table_id
  destination_cidr_block    = data.terraform_remote_state.lab1.outputs.vpc_1_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
}
