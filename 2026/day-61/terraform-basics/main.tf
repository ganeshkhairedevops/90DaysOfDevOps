terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}


resource "aws_s3_bucket" "My_bucket" {
  bucket = "terraweek-ganesh2026"  # globally unique name
}

resource "aws_instance" "ec2" {
  ami           = "ami-0ec10929233384c7f"
  instance_type = "t2.micro" 

  tags = {
    Name = "TerraWeek-Day1"
  }
}
