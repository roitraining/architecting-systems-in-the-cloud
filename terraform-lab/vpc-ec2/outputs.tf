# Outputs for Lab 1: VPC and EC2 Setup
# These outputs will be used by Lab 2 and Lab 3

output "vpc_1_id" {
  description = "ID of VPC 1"
  value       = aws_vpc.vpc_1.id
}

output "vpc_1_cidr" {
  description = "CIDR block of VPC 1"
  value       = aws_vpc.vpc_1.cidr_block
}

output "vpc_2_id" {
  description = "ID of VPC 2"
  value       = aws_vpc.vpc_2.id
}

output "vpc_2_cidr" {
  description = "CIDR block of VPC 2"
  value       = aws_vpc.vpc_2.cidr_block
}

output "vpc_1_route_table_id" {
  description = "Route table ID for VPC 1"
  value       = aws_route_table.vpc_1_rt.id
}

output "vpc_2_route_table_id" {
  description = "Route table ID for VPC 2"
  value       = aws_route_table.vpc_2_rt.id
}

output "vpc_1_instance_id" {
  description = "Instance ID in VPC 1"
  value       = aws_instance.vpc_1_instance.id
}

output "vpc_1_instance_private_ip" {
  description = "Private IP of instance in VPC 1"
  value       = aws_instance.vpc_1_instance.private_ip
}

output "vpc_2_instance_id" {
  description = "Instance ID in VPC 2"
  value       = aws_instance.vpc_2_instance.id
}

output "vpc_2_instance_private_ip" {
  description = "Private IP of instance in VPC 2"
  value       = aws_instance.vpc_2_instance.private_ip
}

output "connection_instructions" {
  description = "Instructions for connecting to instances"
  value = <<-EOT
    
    ========================================
    Lab 1: VPC and EC2 Setup - Complete!
    ========================================
    
    VPC 1 Instance:
      - Instance ID: ${aws_instance.vpc_1_instance.id}
      - Private IP: ${aws_instance.vpc_1_instance.private_ip}
      - Connect: Use AWS Systems Manager Session Manager
    
    VPC 2 Instance:
      - Instance ID: ${aws_instance.vpc_2_instance.id}
      - Private IP: ${aws_instance.vpc_2_instance.private_ip}
      - Connect: Use AWS Systems Manager Session Manager
    
    Connection Method (No Internet Gateway):
      1. AWS Console → EC2 → Instances
      2. Select instance → Connect → Session Manager
      3. Click "Connect"
    
    Next Steps:
      1. Connect to VPC 1 instance via Session Manager
      2. Try to ping VPC 2 instance: ping ${aws_instance.vpc_2_instance.private_ip}
      3. This should FAIL - no connectivity yet!
      4. Proceed to Lab 2 to add VPC peering
    
    Note: Instances have no internet access (no IGW)
    
    ========================================
  EOT
}
