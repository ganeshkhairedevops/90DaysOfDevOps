# EC2 Instance Module

## Overview

This module provisions an AWS EC2 instance with configurable parameters such as AMI, instance type, subnet, and security groups.

It is designed to be reusable across multiple environments.

## Module Structure
```
modules/ec2-instance/
├── main.tf        # EC2 instance resource definition
├── variables.tf   # Input variable declarations
├── outputs.tf     # Output value declarations
└── README.md      
```

---

## Usage
To use this module, call it from your root module like this: `main.tf`

```hcl
module "web_server" {
  source = "./modules/ec2-instance"

  ami_id             = data.aws_ami.amazon_linux_2.id
  instance_type      = "t3.micro"
  subnet_id          = module.vpc.public_subnets[0]
  security_group_ids = [module.web_sg.sg_id]
  instance_name      = "terraweek-web"

  tags = {
    Owner     = "Your Name"
    ManagedBy = "Terraform"
  }
}
```

---

## Inputs Variables (variables.tf)

| Name               | Type         | Default  | Description                |
| ------------------ | ------------ | -------- | -------------------------- |
| ami_id             | string       | n/a      | AMI ID for the instance    |
| instance_type      | string       | t2.micro | EC2 instance type          |
| subnet_id          | string       | n/a      | Subnet ID                  |
| security_group_ids | list(string) | n/a      | List of security group IDs |
| instance_name      | string       | n/a      | Name tag for the instance  |
| tags               | map(string)  | {}       | Additional tags            |

---

## Outputs (outputs.tf)

| Name        | Description            |
| ----------- | ---------------------- |
| instance_id | ID of the EC2 instance |
| public_ip   | Public IP address      |
| private_ip  | Private IP address     |

Reference outputs from root like:
```hcl
module.web_server.public_ip
module.web_server.instance_id
```

---

## How It Works (main.tf)
1. The module creates an EC2 instance using the provided AMI, instance type, subnet, and security groups.
2. The `Name` tag is set using the `instance_name` variable.
3. Additional tags are merged with the Name tag using the `merge()` function.
4. The module outputs the instance ID, public IP, and private IP for use in other parts of your configuration.

```
resource "aws_instance" "ec2" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = var.security_group_ids
  associate_public_ip_address = true

  tags = merge(
    { Name = var.instance_name },
    var.tags
  )
}
```

## Notes

* The `Name` tag is automatically added using `instance_name`.
* Additional tags are merged using Terraform's `merge()` function.
* Ensure the subnet is in a public VPC if public IP is required.
* This module does not handle key pairs or user data for simplicity. You can extend it as needed.
