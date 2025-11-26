# Outputs for VPC Peering Demo

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

output "vpc_peering_connection_id" {
  description = "ID of the VPC peering connection"
  value       = aws_vpc_peering_connection.peer.id
}

output "vpc_peering_status" {
  description = "Status of the VPC peering connection"
  value       = aws_vpc_peering_connection.peer.accept_status
}

output "vpc_1_subnet_id" {
  description = "ID of VPC 1 subnet"
  value       = aws_subnet.vpc_1_subnet.id
}

output "vpc_2_subnet_id" {
  description = "ID of VPC 2 subnet"
  value       = aws_subnet.vpc_2_subnet.id
}

output "vpc_1_security_group_id" {
  description = "ID of VPC 1 security group"
  value       = aws_security_group.vpc_1_sg.id
}

output "vpc_2_security_group_id" {
  description = "ID of VPC 2 security group"
  value       = aws_security_group.vpc_2_sg.id
}

output "summary" {
  description = "Summary of the VPC peering setup"
  value = <<-EOT
    
    ========================================
    VPC Peering Demo - Deployment Summary
    ========================================
    
    VPC 1 (Production):
      - VPC ID: ${aws_vpc.vpc_1.id}
      - CIDR: ${aws_vpc.vpc_1.cidr_block}
      - Subnet ID: ${aws_subnet.vpc_1_subnet.id}
      - Security Group: ${aws_security_group.vpc_1_sg.id}
    
    VPC 2 (Development):
      - VPC ID: ${aws_vpc.vpc_2.id}
      - CIDR: ${aws_vpc.vpc_2.cidr_block}
      - Subnet ID: ${aws_subnet.vpc_2_subnet.id}
      - Security Group: ${aws_security_group.vpc_2_sg.id}
    
    VPC Peering:
      - Connection ID: ${aws_vpc_peering_connection.peer.id}
      - Status: ${aws_vpc_peering_connection.peer.accept_status}
    
    Next Steps:
      1. Launch EC2 instances in each VPC to test connectivity
      2. Use the security groups created above
      3. Test ping between instances using private IPs
    
    ========================================
  EOT
}
