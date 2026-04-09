# Variables for VPC module
# This file defines the variables for the VPC module, which include the CIDR block for
variable "cidr" {
    description = "CIDR block for vpc"
    type        = string
}

variable "public_subnet_cidr" {
    description = "CIDR block for public subnet"
    type        = string
}

variable "environment" {
    description = "Environment name"
    type        = string
}

variable "project_name" {
    description = "Project name"
    type        = string
}