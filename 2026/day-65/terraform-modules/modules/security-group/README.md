# Security Group Module

A reusable Terraform module that creates an AWS Security Group with dynamic ingress rules based on a list of ports, and a permissive egress rule for all outbound traffic.

## Module Structure
```
modules/security-group/
├── main.tf        # Security group resource with dynamic ingress block
├── variables.tf   # Input variable declarations
├── outputs.tf     # Output value declarations
└── README.md      
```
## Usage
To use this module, call it from your root module like this: `main.tf`

```hcl
module "web_sg" {
  source = "./modules/security-group"

  vpc_id        = module.vpc.vpc_id
  sg_name       = "terraweek-web-sg"
  ingress_ports = [22, 80, 443]

  tags = {
    Owner     = "Your Name"
    ManagedBy = "Terraform"
  }
}
```
---
## Input Variables (variables.tf)
| Name          | Type         | Default  | Description                         |
| ------------- | ------------ | -------- | ----------------------------------- |
| vpc_id        | string       | n/a      | ID of the VPC to create the SG in   |
| sg_name       | string       | n/a      | Name for the security group          |
| ingress_ports | list(number) | [22, 80] | List of ports to allow for ingress   |
| tags          | map(string)  | {}       | Additional tags for the security group |

## Outputs (outputs.tf)
| Name  | Description                     |
| ----- | ------------------------------- |
| sg_id | ID of the created security group |
Reference outputs from root like:
```hcl
module.web_sg.sg_id
```
Pass it into the EC2 module:
```hcl
security_group_ids = [module.web_sg.sg_id]
```

## How It Works (main.tf)
1. The `aws_security_group` resource is created in the specified VPC with the given name and tags.
2. The `dynamic "ingress"` block iterates over the `ingress_ports` list to create an ingress rule for each port, allowing TCP traffic from anywhere
3. An egress rule is defined to allow all outbound traffic.
```hcl
resource "aws_security_group" "sg" {
  name        = var.sg_name
  description = "Security group with dynamic allowed ports"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.ingress_ports
    content {
      description = "Allow Inbound"
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    { Name = var.sg_name }
  )
}
```

## Key Points
- The `dynamic` block allows us to generate multiple ingress rules based on the list of ports provided, making the module flexible and reusable.
- The egress rule is set to allow all outbound traffic, which is common for security groups unless you have specific restrictions in mind.
---