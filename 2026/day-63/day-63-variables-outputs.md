# 📘 Day 63 – Variables, Outputs, Data Sources & Expressions

## 🚀 Overview

On Day 62, my Terraform configuration worked but had hardcoded values like region, AMI, CIDR blocks, and instance type. This made it difficult to reuse across environments.

Today, I refactored the entire setup to make it **dynamic, reusable, and environment-aware** using variables, outputs, data sources, and expressions.

---
## Challenge Tasks
### Task 1: Extract Variables

## 🧩 Variables (variables.tf)

Take your Day 62 infrastructure config and refactor it:

1. Create a `variables.tf` file with input variables for:
   - `region` (string, default: your preferred region)
   - `vpc_cidr` (string, default: `"10.0.0.0/16"`)
   - `subnet_cidr` (string, default: `"10.0.1.0/24"`)
   - `instance_type` (string, default: `"t2.micro"`)
   - `project_name` (string, no default -- force the user to provide it)
   - `environment` (string, default: `"dev"`)
   - `allowed_ports` (list of numbers, default: `[22, 80, 443]`)
   - `extra_tags` (map of strings, default: `{}`)

2. Replace every hardcoded value in `main.tf` with `var.<name>` references
3. Run `terraform plan` -- it should prompt you for `project_name` since it has no default

![task1]()

**Document:** What are the five variable types in Terraform? (`string`, `number`, `bool`, `list`, `map`)
- `string` names or any text
    
    ```hcl
    variable "project_name" {
      type = string
      default = "dev"
    }
    # use in resource
    resource "aws_instance" "main" {
      # ...
      tags = {
        Name = var.project_name
      }
    }
    ```
- `number` numeric values
    ```hcl
    variable "instance_count" {
      type    = number
      default = 2
    }
    # use in resource
    resource "aws_instance" "main" {
      count = var.instance_count
      # ...
    }
    ```

- `bool` true/false values
    ```hcl
    variable "enable_monitoring" {
      type    = bool
      default = false
    }
    # use in resource
    resource "aws_instance" "main" {
      monitoring = var.enable_monitoring
      # ...
    }
    ```
- `list` ordered collection of values
    ```hcl
      variable "security_groups" {
      type    = list(string)
      default = ["sg-1", "sg-2"]
      }

      # Usage in resource
      vpc_security_group_ids = var.security_groups
    ```
- `map` key-value pairs
    ```bash
      variable "s3_buckets" {
      type = map(string)
      default = {
         bucket1 = "us-east-1"
         bucket2 = "us-west-2"
         }
      }

      # Usage in resource
      for_each = var.s3_buckets
      bucket   = each.key
      region   = each.value
   ```


---
### Task 2: Variable Files and Precedence
1. Create a `terraform.tfvars`:
```hcl
project_name = "terraweek"
environment  = "dev"
instance_type = "t2.micro"
```
2.  Create `prod.tfvars`:
```hcl
project_name = "terraweek"
environment  = "prod"
instance_type = "t3.small"
vpc_cidr     = "10.1.0.0/16"
subnet_cidr  = "10.1.1.0/24"
```
3. 3. Apply with the default file:
```bash
terraform plan                              # Uses terraform.tfvars automatically
```
![task2]()

4. Apply with the prod file:
```bash
terraform plan -var-file="prod.tfvars"      # Uses prod.tfvars
```
![task2.1]()

5. Override with CLI:
```bash
terraform plan -var="instance_type=t2.nano"  # CLI overrides everything
```
![task2.3]()

6. Set an environment variable:
```bash
export TF_VAR_environment="staging"
terraform plan                              # env var overrides default but not tfvars
```
![task2.4]()

- export TF_VAR_environment="staging" overrides only the default in variables.tf, but does not override terraform.tfvars.
- terraform.tfvars have environment = dev, Terraform uses "dev"

**Document:** Write the variable precedence order from lowest to highest priority.
1. Default values
2. terraform.tfvars
3. *.auto.tfvars
4. -var-file
5. -var
6. TF_VAR_* environment variables

---
### Task 3: Add Outputs
Create an `outputs.tf` file with outputs for:

1. `vpc_id` -- the VPC ID
2. `subnet_id` -- the public subnet ID
3. `instance_id` -- the EC2 instance ID
4. `instance_public_ip` -- the public IP of the EC2 instance
5. `instance_public_dns` -- the public DNS name
6. `security_group_id` -- the security group ID

Apply your config and verify the outputs are printed at the end:
```bash
terraform apply

# After apply, you can also run:
terraform output                          # Show all outputs
terraform output instance_public_ip       # Show a specific output
terraform output -json                    # JSON format for scripting
```

![task3]()

**Verify:** Does `terraform output instance_public_ip` return the correct IP?
- Yes, `terraform output instance_public_ip` returns the correct IP.

![task3.1]()

---
### Task 4: Use Data Sources
Stop hardcoding the AMI ID. Use a data source to fetch it dynamically.

1. Add a `data "aws_ami"` block that:
   - Filters for Amazon Linux 2 images
   - Filters for `hvm` virtualization and `gp2` root device
   - Uses `owners = ["amazon"]`
   - Sets `most_recent = true`

2. Replace the hardcoded AMI in your `aws_instance` with `data.aws_ami.amazon_linux.id`

3. Add a `data "aws_availability_zones"` block to fetch available AZs in your region

4. Use the first AZ in your subnet: `data.aws_availability_zones.available.names[0]`

Apply and verify -- your config now works in any region without changing the AMI.

![task4]()

**Document:** What is the difference between a `resource` and a `data` source?
- A `resource` creates infrastructure (like EC2 instances, VPCs, etc.), while a `data` source fetches existing information (like AMI IDs, availability zones, etc.) without creating anything.

* **Resource** → creates infrastructure (EC2, VPC, etc.)
* **Data Source** → fetches existing information (AMI, AZs)

  | Feature           | `resource`           | `data`                        |
   | ----------------- | -------------------- | ----------------------------- |
   | Creates infra     |   Yes                |    No                          |
   | Managed by TF     |   Yes                |    No                          |
   | Stored in state   |   Yes                |     Read-only reference        |
   | Lifecycle actions | create/update/delete | read-only                     |
   | Use case          | EC2, VPC, Subnet     | AMI lookup, AZs, existing VPC |

---
### Task 5: Use Locals for Dynamic Values
1. Add a `locals` block:
```hcl
locals {
  name_prefix = "${var.project_name}-${var.environment}"
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
```

2. Replace all Name tags with `local.name_prefix`:
   - VPC: `"${local.name_prefix}-vpc"`
   - Subnet: `"${local.name_prefix}-subnet"`
   - Instance: `"${local.name_prefix}-server"`

3. Merge common tags with resource-specific tags:
```hcl
tags = merge(local.common_tags, {
  Name = "${local.name_prefix}-server"
})
```

Apply and check the tags in the AWS console -- every resource should have consistent tagging.

![task5]()


---

### Task 6: Built-in Functions and Conditional Expressions
Practice these in `terraform console`:
```bash
terraform console
```

1. **String functions:**
   - `upper("terraweek")` -> `"TERRAWEEK"`
   - `join("-", ["terra", "week", "2026"])` -> `"terra-week-2026"`
   - `format("arn:aws:s3:::%s", "my-bucket")`

2. **Collection functions:**
   - `length(["a", "b", "c"])` -> `3`
   - `lookup({dev = "t2.micro", prod = "t3.small"}, "dev")` -> `"t2.micro"`
   - `toset(["a", "b", "a"])` -> removes duplicates

3. **Networking function:**
   - `cidrsubnet("10.0.0.0/16", 8, 1)` -> `"10.0.1.0/24"`

4. **Conditional expression** -- add this to your config:
```hcl
instance_type = var.environment == "prod" ? "t3.small" : "t2.micro"  
```
im taking t3.micro, t2.micro not available for me

instance_type = var.environment == "prod" ? "t3.small" : `"t3.micro"


Apply with `environment = "prod"` and verify the instance type changes.

![task6]()

**Document:** Pick five functions you find most useful and explain what each does.
1. `upper(string)` - Converts a string to uppercase.
    - upper(var.environment)   `"dev" → "DEV"`
2. `join(separator, list)` - Joins a list of strings into a single string with a separator.
    - join("-", ["terra", "week"])   `"terra-week"`
3. `format(format_string, args...)` - Formats a string using placeholders.
    - format("arn:aws:s3:::%s", "my-bucket")   `"arn:aws:s3:::my-bucket"`
4. `length(collection)` - Returns the number of elements in a collection (list, map, etc.).
    - length(["a", "b", "c"])   `3`
5. `lookup(map, key, default)` - Looks up a value in a map by key, with an optional default if the key is not found.
    - lookup({dev = "t2.micro", prod = "t3.small"}, "dev")   `"t2.micro"`

---

## 🧾 Summary

* Converted static config into dynamic reusable infrastructure
* Removed hardcoded values using variables
* Used data sources for dynamic AMI and AZ
* Implemented outputs for visibility
* Applied conditional logic and functions

 Now Terraform code can be reused across multiple environments like dev, staging, and production.

---
