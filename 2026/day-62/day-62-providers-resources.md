# Day 62 -- Providers, Resources and Dependencies

## Challenge Tasks

### Task 1: Explore the AWS Provider
1. Create a new project directory: `terraform-aws-infra`
2. Write a `providers.tf` file:
   - Define the `terraform` block with `required_providers` pinning the AWS provider to version `~> 5.0`
   - Define the `provider "aws"` block with your region
3. Run `terraform init` and check the output -- what version was installed?
    - v5.100.0 version installed

    ![task1](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/bc5cdfb23023eb31c6b537012889b1eb462706b4/2026/day-62/images/task%201.JPG)

4. Read the provider lock file `.terraform.lock.hcl` -- what does it do?
    - The `.terraform.lock.hcl` file is used to lock the versions of the providers that Terraform uses. It ensures that the same version of the provider is used across different runs and environments, preventing unexpected changes due to provider updates.

**Document:** What does `~> 5.0` mean? How is it different from `>= 5.0` and `= 5.0.0`?

- `~> 5.0` means that Terraform will use any version of the provider that is greater than or equal to 5.0 but less than 6.0. It allows for patch and minor updates within the major version 5.
- `>= 5.0` means that Terraform will use any version of the provider that is greater than or equal to 5.0, including major versions like 6.0, which could potentially introduce breaking changes.
- `= 5.0.0` means that Terraform will use exactly version 5.0.0 of the provider, and no other versions will be accepted.

---
### Task 2: Build a VPC from Scratch
Create a `main.tf` and define these resources one by one:
1. `aws_vpc` -- CIDR block `10.0.0.0/16`, tag it `"TerraWeek-VPC"`
2. `aws_subnet` -- CIDR block `10.0.1.0/24`, reference the VPC ID from step 1, enable public IP on launch, tag it `"TerraWeek-Public-Subnet"`
3. `aws_internet_gateway` -- attach it to the VPC
4. `aws_route_table` -- create it in the VPC, add a route for `0.0.0.0/0` pointing to the internet gateway
5. `aws_route_table_association` -- associate the route table with the subnet
Run `terraform plan` -- you should see 5 resources to create.

![task2](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/bc5cdfb23023eb31c6b537012889b1eb462706b4/2026/day-62/images/task%202.jpg)

**Verify:** Apply and check the AWS VPC console. Can you see all five resources connected?
- Yes, all five resources are connected in the AWS VPC console.

![task2.1](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/bc5cdfb23023eb31c6b537012889b1eb462706b4/2026/day-62/images/task%202.1.jpg)

![task2.2](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/bc5cdfb23023eb31c6b537012889b1eb462706b4/2026/day-62/images/task%202.2.jpg)

---
### Task 3: Understand Implicit Dependencies
Look at your `main.tf` carefully:

1. The subnet references `aws_vpc.main.id` -- this is an implicit dependency
2. The internet gateway references the VPC ID -- another implicit dependency
3. The route table association references both the route table and the subnet

Answer these questions:
- How does Terraform know to create the VPC before the subnet?
    - Terraform automatically detects the dependencies between resources based on the references in the configuration. Since the subnet references the VPC ID, Terraform understands that the VPC must be created before the subnet.
- What would happen if you tried to create the subnet before the VPC existed?
    - If you tried to create the subnet before the VPC existed, Terraform would fail with an error because the subnet cannot be created without a valid VPC to associate with.
- Find all implicit dependencies in your config and list them
    - The subnet depends on the VPC.
    - The internet gateway depends on the VPC.
    - The route table depends on the VPC.
    - The route table association depends on both the route table and the subnet.
---
### Task 4: Add a Security Group and EC2 Instance
Add to your config:

1. `aws_security_group` in the VPC:
   - Ingress rule: allow SSH (port 22) from `0.0.0.0/0`
   - Ingress rule: allow HTTP (port 80) from `0.0.0.0/0`
   - Egress rule: allow all outbound traffic
   - Tag: `"TerraWeek-SG"`

2. `aws_instance` in the subnet:
   - Use Amazon Linux 2 AMI for your region
   - Instance type: `t2.micro`
   - Associate the security group
   - Set `associate_public_ip_address = true`
   - Tag: `"TerraWeek-Server"`

Apply and verify -- your EC2 instance should have a public IP and be reachable.
- Yes, the EC2 instance has a public IP and is reachable.

![task4](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/bc5cdfb23023eb31c6b537012889b1eb462706b4/2026/day-62/images/task%204.jpg)

Public IP Address

![task4.1](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/bc5cdfb23023eb31c6b537012889b1eb462706b4/2026/day-62/images/task%204.1.jpg)

AWS Security Group

![task4.2](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/bc5cdfb23023eb31c6b537012889b1eb462706b4/2026/day-62/images/task%204.2.jpg)

![task4.3](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/bc5cdfb23023eb31c6b537012889b1eb462706b4/2026/day-62/images/task%204.3.jpg)

Access using Public IP

![task4.4](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/bc5cdfb23023eb31c6b537012889b1eb462706b4/2026/day-62/images/task%204.4.jpg)

---
### Task 5: Explicit Dependencies with depends_on
Sometimes Terraform cannot detect a dependency automatically.

1. Add a second `aws_s3_bucket` resource for application logs
2. Add `depends_on = [aws_instance.main]` to the S3 bucket -- even though there is no direct reference, you want the bucket created only after the instance
3. Run `terraform plan` and observe the order

Now visualize the entire dependency tree:
```bash
terraform graph | dot -Tpng > graph.png
```
![task5](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/bc5cdfb23023eb31c6b537012889b1eb462706b4/2026/day-62/images/task%205.jpg)

If you don't have `dot` (Graphviz) installed, use:
```bash
terraform graph
```
and paste the output into an online Graphviz viewer.

![graph](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/bc5cdfb23023eb31c6b537012889b1eb462706b4/2026/day-62/terraform-aws-infra/graph.png)

**Document:** When would you use `depends_on` in real projects? Give two examples.
- You would use `depends_on` in real projects when you have resources that do not have direct references to each other but still need to be created in a specific order. For example:
  1. If you have an S3 bucket that should only be created after an EC2 instance is up and running, you would use `depends_on` to ensure the bucket is created after the instance.
  2. If you have a database resource that should only be created after a VPC and subnet are set up, you would use `depends_on` to enforce this order of creation.

---
### Task 6: Lifecycle Rules and Destroy
1. Add a `lifecycle` block to your EC2 instance:
```hcl
lifecycle {
  create_before_destroy = true
}
```
2. Change the AMI ID to a different one and run `terraform plan` -- observe that Terraform plans to create the new instance before destroying the old one
- Yes, Terraform plans to create the new instance before destroying the old one due to the `create_before_destroy` lifecycle rule. This ensures that there is no downtime during the update process.

![task6](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/bc5cdfb23023eb31c6b537012889b1eb462706b4/2026/day-62/images/task%206.1.jpg)

3. Destroy everything:
```bash
terraform destroy
```
- Yes, all resources are destroyed successfully without any issues.

4. Watch the destroy order -- Terraform destroys in reverse dependency order. Verify in the AWS console that everything is cleaned up.
- Yes, Terraform destroys resources in reverse dependency order, and the AWS console confirms that everything has been cleaned up.

![task6.1](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/bc5cdfb23023eb31c6b537012889b1eb462706b4/2026/day-62/images/task%206.2.jpg)

![task6](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/bc5cdfb23023eb31c6b537012889b1eb462706b4/2026/day-62/images/task%206.2.jpg)

**Document:** What are the three lifecycle arguments (`create_before_destroy`, `prevent_destroy`, `ignore_changes`) and when would you use each?
- `create_before_destroy`: This argument ensures that when a resource is updated, the new resource is created before the old one is destroyed. This is useful for resources that require high availability and cannot afford downtime during updates, such as EC2 instances or load balancers.
- `prevent_destroy`: This argument prevents a resource from being destroyed. If you try to destroy a resource with this lifecycle rule, Terraform will throw an error. This is useful for critical resources that should never be accidentally deleted, such as databases or S3 buckets containing important data.
- `ignore_changes`: This argument tells Terraform to ignore changes to specific attributes of a resource. This is useful when certain attributes are managed outside of Terraform or when you want to prevent Terraform from making changes to attributes that are frequently updated by other processes, such as tags or metadata.

---

### implicit vs explicit dependencies
- Implicit dependencies are automatically detected by Terraform based on references between resources. For example, if a subnet references a VPC ID, Terraform knows that the VPC must be created before the subnet.
- Explicit dependencies are defined using the `depends_on` argument when there is no direct reference between resources, but you still want to enforce a specific creation order. For example, if you want an S3 bucket to be created only after an EC2 instance is up, you would use `depends_on` to specify this relationship.
