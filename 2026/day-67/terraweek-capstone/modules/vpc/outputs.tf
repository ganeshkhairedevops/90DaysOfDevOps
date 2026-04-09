# Outputs for VPC module
# This file defines the outputs for the VPC module, which include the VPC ID and the Public Subnet ID. These outputs can be used by other modules or by the root module to reference the created resources.
output "vpc_id" {
  description = "Vpc Id"
  value       = aws_vpc.vpc.id
}

output "subnet_id" {
  description = "Public Subnet Id"
  value       = aws_subnet.public_subnet.id
}