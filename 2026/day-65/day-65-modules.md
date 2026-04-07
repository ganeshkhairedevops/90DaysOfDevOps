# Day 65 -- Terraform Modules: Build Reusable Infrastructure

## Overview

Until now, I was writing all Terraform code in a single main.tf file. While it worked, it was not scalable or reusable.

Today, I learned how to use Terraform Modules — a way to organize, reuse, and standardize infrastructure code.

Modules are like functions — write once, reuse everywhere.

---
## Challenge Tasks

### Task 1: Understand Module Structure
A Terraform module is just a directory with `.tf` files. Create this structure:

```
terraform-modules/
  main.tf                    # Root module -- calls child modules
  variables.tf               # Root variables
  outputs.tf                 # Root outputs
  providers.tf               # Provider config
  modules/
    ec2-instance/
      main.tf                # EC2 resource definition
      variables.tf           # Module inputs
      outputs.tf             # Module outputs
    security-group/
      main.tf                # Security group resource definition
      variables.tf           # Module inputs
      outputs.tf             # Module outputs
```

Create all the directories and empty files. This is the standard layout every Terraform project follows.

![task1]()

**Document:** What is the difference between a "root module" and a "child module"?
- **Root module:** The configuration in the top-level directory that Terraform runs first (calls child modules, defines providers, variables, outputs).
    
    The root module is the main place where everything starts.

- **Child module:** Any directory called via module "name" { source = ... } that encapsulates reusable resources.
    
    A child module is a smaller part used by the root module.

---
### Task 2: Build a Custom EC2 Module
Create `modules/ec2-instance/`:
1. **`variables.tf`** -- define inputs:
   - `ami_id` (string)
   - `instance_type` (string, default: `"t2.micro"`)
   - `subnet_id` (string)
   - `security_group_ids` (list of strings)
   - `instance_name` (string)
   - `tags` (map of strings, default: `{}`)
2. **`main.tf`** -- define the resource:
   - `aws_instance` using all the variables
   - Merge the Name tag with additional tags

3. **`outputs.tf`** -- expose:
   - `instance_id`
   - `public_ip`
   - `private_ip`

    Do NOT apply yet -- just write the module.

---

### Task 3: Build a Custom Security Group Module
Create `modules/security-group/`:

1. **`variables.tf`** -- define inputs:
   - `vpc_id` (string)
   - `sg_name` (string)
   - `ingress_ports` (list of numbers, default: `[22, 80]`)
   - `tags` (map of strings, default: `{}`)

2. **`main.tf`** -- define the resource:
   - `aws_security_group` in the given VPC
   - Use `dynamic "ingress"` block to create rules from the `ingress_ports` list
   - Allow all egress

3. **`outputs.tf`** -- expose:
   - `sg_id`

This is your first time using a `dynamic` block -- it loops over a list to generate repeated nested blocks.

---
### Task 4: Call Your Modules from Root
In the root `main.tf`, wire everything together:

1. Create a VPC and subnet directly (or reuse your Day 62 config)
2. Call the security group module:
```hcl
module "web_sg" {
  source        = "./modules/security-group"
  vpc_id        = aws_vpc.main.id
  sg_name       = "terraweek-web-sg"
  ingress_ports = [22, 80, 443]
  tags          = local.common_tags
}
```

3. Call the EC2 module -- deploy **two instances** with different names using the same module:
```hcl
module "web_server" {
  source             = "./modules/ec2-instance"
  ami_id             = data.aws_ami.amazon_linux.id
  instance_type      = "t2.micro"
  subnet_id          = aws_subnet.public.id
  security_group_ids = [module.web_sg.sg_id]
  instance_name      = "terraweek-web"
  tags               = local.common_tags
}

module "api_server" {
  source             = "./modules/ec2-instance"
  ami_id             = data.aws_ami.amazon_linux.id
  instance_type      = "t2.micro"
  subnet_id          = aws_subnet.public.id
  security_group_ids = [module.web_sg.sg_id]
  instance_name      = "terraweek-api"
  tags               = local.common_tags
}
```

4. Add root outputs that reference module outputs:
```hcl
output "web_server_ip" {
  value = module.web_server.public_ip
}

output "api_server_ip" {
  value = module.api_server.public_ip
}
```

5. Apply:
```bash
terraform init    # Downloads/links the local modules
terraform plan    # Should show all resources from both module calls
terraform apply
```
![task4.5]()

![task4]()


**Verify:** Two EC2 instances running, same security group, different names. Check the AWS console.

![task4.1]()

![task4.2]()

![task4.3]()

![task4.4]()

---
### Task 5: Use a Public Registry Module
Instead of building your own VPC from scratch, use the official module from the Terraform Registry.

1. Replace your hand-written VPC resources with:
```hcl
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "terraweek-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["ap-south-1a", "ap-south-1b"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.3.0/24", "10.0.4.0/24"]

  enable_nat_gateway = false
  enable_dns_hostnames = true

  tags = local.common_tags
}
```

2. Update your EC2 and SG module calls to reference `module.vpc.vpc_id` and `module.vpc.public_subnets[0]`

3. Run:
```bash
terraform init     # Downloads the registry module
terraform plan
terraform apply
```
![task5]()

![task5.2]()


4. Compare: how many resources did the VPC module create vs your hand-written VPC from Day 62?
- The VPC module created 10+ resources (VPC, subnets, route tables, IGW, etc.) while my hand-written VPC had only 3 resources. The module abstracts away all the underlying components needed for a functional VPC.

![task5.1]()

---

### Task 6: Module Versioning and Best Practices
1. Pin your registry module version explicitly:
   - `version = "5.1.0"` -- exact version
   - `version = "~> 5.0"` -- any 5.x version
   - `version = ">= 5.0, < 6.0"` -- range

2. Run `terraform init -upgrade` to check for newer versions

![task 6]

3. Check the state to see how modules appear:
```bash
terraform state list
```
Notice the `module.vpc.`, `module.web_server.`, `module.web_sg.` prefixes.

![task6.1]()

4. Destroy everything:
```bash
terraform destroy
```
![task6.2]()

---

### Hand-Written VPC vs Registry VPC Module
| Aspect                 | Hand-Written VPC (Day 62) | Registry VPC Module (Day 65) |
|------------------------|----------------------------|-------------------------------|
| Resources Created      | 3 (VPC, Subnet, IGW)       | 10+ (VPC, subnets, route tables, IGW, etc.) |
| Complexity             | Simple, minimal setup      | More complex, production-ready |
| Reusability            | Low (custom code)          | High (standardized module)     |
| Maintenance            | Manual updates needed      | Maintained by module authors   |
| Best Practice          | Not following DRY principle | Follows DRY, modular design   |


### Module best practices:
1. **Use Modules for Reusability**: Encapsulate common infrastructure patterns in modules to avoid code duplication and promote reuse across projects.
2. **Pin Module Versions**: Always specify exact or compatible versions for registry modules to ensure stability and avoid unexpected changes when new versions are released.
3. **Use Variables and Outputs**: Design modules with clear input variables and output values to make them flexible and easy to integrate.
4. **Document Module Usage**: Provide clear documentation on how to use the module, including required variables, expected outputs, and any assumptions or dependencies.
5. **Test Modules Independently**: Before integrating a module into your main configuration, test it in isolation to ensure it works as expected and handles edge cases properly.
