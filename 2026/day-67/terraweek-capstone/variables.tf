#  Variables for the main Terraform configuration
# This file defines the input variables for the main Terraform configuration, including AWS region, project name
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}


variable "project_name" {
  type    = string
  default = "terraweek"
}

variable "vpc_cidr" {
  type = string
}

variable "subnet_cidr" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "ingress_ports" {
  type    = list(number)
  default = [22, 80]
}