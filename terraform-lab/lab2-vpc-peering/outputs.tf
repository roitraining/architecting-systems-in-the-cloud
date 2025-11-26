# Outputs for Lab 2: VPC Peering

output "vpc_peering_connection_id" {
  description = "ID of the VPC peering connection"
  value       = aws_vpc_peering_connection.peer.id
}

output "vpc_peering_status" {
  description = "Status of the VPC peering connection"
  value       = aws_vpc_peering_connection.peer.accept_status
}

output "test_instructions" {
  description = "Instructions for testing VPC peering"
  value = <<-EOT
    
    ========================================
    Lab 2: VPC Peering - Complete!
    ========================================
    
    VPC Peering Connection:
      - Connection ID: ${aws_vpc_peering_connection.peer.id}
      - Status: ${aws_vpc_peering_connection.peer.accept_status}
    
    Test Connectivity:
      1. Connect to VPC 1 instance (${data.terraform_remote_state.lab1.outputs.vpc_1_instance_id})
      2. Ping VPC 2 instance: ping ${data.terraform_remote_state.lab1.outputs.vpc_2_instance_private_ip}
      3. This should now WORK! ✓
    
    What Changed:
      - VPC peering connection created
      - Routes added to both route tables
      - Security groups already allow ICMP traffic
    
    Next Steps:
      - Proceed to Lab 3 to add IAM roles and S3 access
    
    ========================================
  EOT
}
