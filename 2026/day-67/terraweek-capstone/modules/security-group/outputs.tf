# Output for the security group module
# This output provides the ID of the security group created by this module, which can be used by other modules or resources that need to reference this security group.
output "sg_id" {
  description = "ID of the security group"
  value       = aws_security_group.sg.id
}