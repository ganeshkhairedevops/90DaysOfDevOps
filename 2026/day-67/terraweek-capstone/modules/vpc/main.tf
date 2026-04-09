# VPC Module - main.tf
# This module creates a VPC with a public subnet, an Internet Gateway, and a route table for the public subnet.
resource "aws_vpc" "vpc" {
    cidr_block = var.cidr
    enable_dns_hostnames = true
    enable_dns_support   = true

  tags = {
    Name        = "${var.environment}-${var.project_name}-VPC"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}
# Create a public subnet in the VPC
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_subnet_cidr
  map_public_ip_on_launch = true
  tags = {
    Name        = "${var.environment}-${var.project_name}-Public-Subnet"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}
# Create an Internet Gateway and attach it to the VPC
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name        = "${var.environment}-${var.project_name}-Internet-Gateway"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}
# Create a route table for the public subnet and add a default route to the Internet Gateway
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name        = "${var.environment}-${var.project_name}-Public-Route-Table"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}
# Associate the public subnet with the route table
resource "aws_route_table_association" "public_rt_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}