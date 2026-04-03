variable "region" {
    description = "AWS region to deploy resources in"
    type        = string
    default     = "us-east-1"
  
}

variable "vpc_cidr" {
    description = "CIDR block for the VPC"
    type        = string
    default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
    description = "CIDR block for the public subnet"
    type        = string
    default     = "10.0.1.0/24"
}

variable "instance_type" {
    description = "EC2 instance type"
    type        = string
    default     = "t2.micro"
}

variable "key_name" {
    description = "ssh key name"
    type = string
    default = "terraserver"
}
variable "project_name" {
    description = "Name of the project for tagging"
    type        = string
}

variable "environment" {
    description = "Environment name"
    type        = string
    default     = "dev"
}

variable "allowed_ports" {
    description = "List of allowed ports for security group"
    type        = list(number)
    default     = [22, 80, 443]
  
}
variable "extra_tags" {
    description = "Additional tags to apply to resources"
    type        = map(string)
    default     = {}
  
}