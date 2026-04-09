# Terraform module to create a security group with dynamic ingress rules based on provided variables.
# This module defines a security group resource that allows inbound traffic on specified ports and allows all outbound traffic. The security group is tagged with the project name, environment, and a managed by tag for better organization and identification in the AWS console.
# The module takes in variables for the VPC ID, a list of allowed inbound ports, the environment name, and the project name to create a security group that can be easily referenced by other resources or modules in the Terraform configuration.
resource "aws_security_group" "sg" {
  name        = "${var.project_name}-${var.environment}-SG"
  description = "Security group with dynamic allowed ports"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.ingress_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }

  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-SG"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }

}