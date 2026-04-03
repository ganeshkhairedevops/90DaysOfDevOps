output "vpc_id" {
    description = "VPC ID"
    value       = aws_vpc.vpc.id
  
}

output "subnet_id" {
    description = "Public Subnet ID"
    value       = aws_subnet.public_subnet.id
}

output "instance_id" {
    description = "EC2 Instance ID"
    value       = aws_instance.ec2.id
}

output "instance_public_ip" {
    description = "EC2 Instance Public IP"
    value       = aws_instance.ec2.public_ip
}

output "instance_public_dns" {
    description = "Public DNS EC2"
    value      = aws_instance.ec2.public_dns
}
output "security_group_id" {
    description = "Security Group ID"
    value       = aws_security_group.ec2-sg.id
  
}