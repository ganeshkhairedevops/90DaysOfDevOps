# Output for the EC2 instance module
# This output provides the ID and public IP address of the EC2 instance created by this module
output "instance_id" {
  description = "ID of the created EC2 instance"
  value       = aws_instance.ec2_instance.id
}

output "public_ip" {
  description = "Public IP address of the created EC2 instance"
  value       = aws_instance.ec2_instance.public_ip
}