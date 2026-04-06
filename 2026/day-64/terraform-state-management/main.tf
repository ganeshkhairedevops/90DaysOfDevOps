# Data source to get the latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux_2_gp3" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

# Data source to get available AZs
data "aws_availability_zones" "available" {
  state = "available"
}

# Locals for common values and tags
locals {
  name_prefix = "${var.project_name}-${var.environment}"
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
} # Define local values for name prefix and common tags to avoid repetition


# VPC
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-VPC"
  }) # Merge common tags with resource-specific Name tag
}

# Public Subnet
# Public Subnet inside vpc
resource "aws_subnet" "public_subnet" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = var.subnet_cidr
  availability_zone = data.aws_availability_zones.available.names[0] # Use the first available AZ
  #map_public_ip_on_launch = true

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-Public-Subnet"
  }) # Merge common tags with resource-specific Name tag
}

# Internet Gateway
# Connect the VPC to the internet
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-IGW"
  }) # Merge common tags with resource-specific Name tag
}


# Route Table
# Route the traffic form subnet to Internet Gateway
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-rt"
  }) # Merge common tags with resource-specific Name tag

}

# Route Table Association
# Link Subnet to the route table
resource "aws_route_table_association" "public_rt_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# Security Group
# Firewall: allow SSH & HTTP, all outbound
resource "aws_security_group" "ec2-sg" {
  name        = "${var.project_name}-${var.environment}-SG" # Use project and environment for unique SG name
  description = "Security group with dynamic allowed ports"
  vpc_id      = aws_vpc.vpc.id

  dynamic "ingress" {
    for_each = var.allowed_ports
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

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-Sg"
  }) # Merge common tags with resource-specific Name tag

}






# EC2 Instance
# Launch a server in public subnet
resource "aws_instance" "ec2" {
  ami                         = data.aws_ami.amazon_linux_2_gp3.id
  #ami                        = data.aws_ami.amazon_linux.id
  #instance_type               = var.instance_type
  #instance_type               = var.instance_type
  instance_type = var.environment == "prod" ? "t3.small" : "t2.micro"
  key_name                    = var.key_name
  subnet_id                   = aws_subnet.public_subnet.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.ec2-sg.id]

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-Server"
  }) # Merge common tags with resource-specific Name tag
  lifecycle {
  create_before_destroy = true
}
}

# Importing an existing S3 bucket created manually in AWS Console
resource "aws_s3_bucket" "imported" {
  bucket = "terraweek-import-test-ganeshkhaire"
}
