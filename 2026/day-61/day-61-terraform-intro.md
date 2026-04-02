# Day 61 -- Introduction to Terraform and Your First AWS Infrastructure

## Task 1: Understand Infrastructure as Code
1. What is Infrastructure as Code (IaC)? Why does it matter in DevOps?
- Infrastructure as Code means managing and provisioning infrastructure (servers, networks, storage, etc.) using code instead of manually creating it through a UI. You write configuration files, and tools like Terraform create and manage resources automatically.

- IaC is important in DevOps because it brings consistency, automation, and version control to infrastructure. It reduces human errors and allows teams to recreate environments quickly.

2. What problems does IaC solve compared to manually creating resources in the AWS console?
- No more manual clicking in the AWS console
- Eliminates configuration drift (things changing unexpectedly)
- Makes infrastructure reproducible
-Easy to scale and replicate

3. How is Terraform different from AWS CloudFormation, Ansible, and Pulumi?

- **Terraform →** Declarative, cloud-agnostic (works with AWS, Azure, GCP)
- **AWS CloudFormation →** AWS-specific IaC tool
- **Ansible →** Mainly configuration management, procedural
- **Pulumi →** Uses programming languages (Python, TS) instead of HCL

4. What does it mean that Terraform is "declarative" and "cloud-agnostic"?
- **Declarative →** You define what you want, Terraform figures out how to do it
- **Cloud-agnostic →** Works across multiple cloud providers, not just AWS

---

## Task 2: Install Terraform and Configure AWS

1. Install Terraform:
```bash
# macOS
brew tap hashicorp/tap
brew install hashicorp/tap/terraform

# Linux (amd64)
wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform

# Windows
choco install terraform
```

2. Verify:
```bash
terraform -version
```
![task2](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/960c33012bc8f51e97664aeca7640d780542ad4c/2026/day-61/images/task%202.JPG)

3. Install and configure the AWS CLI:

Install AWS CLI
```bash
sudo apt update && sudo apt install -y curl unzip
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
```
Extract and install:
```bash
unzip awscliv2.zip
sudo ./aws/install
```
Verify AWS CLI:
```bash
aws --version
```
![task2.1](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/960c33012bc8f51e97664aeca7640d780542ad4c/2026/day-61/images/task%202.1.JPG)

AWS configure
```bash
aws configure
# Enter your Access Key ID, Secret Access Key, default region (e.g., ap-south-1), output format (json)
```
4. Verify AWS access:
```bash
aws sts get-caller-identity
```
You should see your AWS account ID and ARN.

![task2.3](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/960c33012bc8f51e97664aeca7640d780542ad4c/2026/day-61/images/task%202.3.JPG)

---
### Task 3: Your First Terraform Config -- Create an S3 Bucket

Create a project directory and write your 
```bash
mkdir terraform-basics && cd terraform-basics
```

Create a file called `main.tf` with:
1. A `terraform` block with `required_providers` specifying the `aws` provider
2. A `provider "aws"` block with your region
3. A `resource "aws_s3_bucket"` that creates a bucket with a globally unique name

Run the Terraform lifecycle:
```bash
terraform init      # Download the AWS provider
terraform plan      # Preview what will be created
terraform apply     # Create the bucket (type 'yes' to confirm)
```
terraform init:

![task3](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/960c33012bc8f51e97664aeca7640d780542ad4c/2026/day-61/images/task%203.JPG)

terraform plan:

![task3.1](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/960c33012bc8f51e97664aeca7640d780542ad4c/2026/day-61/images/task%203.1.JPG)

terraform apply:

![task3.2](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/960c33012bc8f51e97664aeca7640d780542ad4c/2026/day-61/images/task%203.2.JPG)

**Document:** What did `terraform init` download? What does the `.terraform/`directory contain?
- `terraform init` downloaded the AWS provider plugin, which allows Terraform to interact with AWS services. 
- `.terraform/` directory contains the provider plugins and any modules that have been initialized for the project.

---
### Task 4: Add an EC2 Instance
In the same `main.tf`, add:
1. A `resource "aws_instance"` using AMI `ami-0f5ee92e2d63afc18` (Amazon Linux 2 in ap-south-1 -- use the correct AMI for your region)
2. Set instance type to `t2.micro`
3. Add a tag: `Name = "TerraWeek-Day1"`

Run:
```bash
terraform plan      # You should see 1 resource to add (bucket already exists)
terraform apply
```
![task4](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/960c33012bc8f51e97664aeca7640d780542ad4c/2026/day-61/images/task%204.JPG)

Go to the AWS EC2 console and verify your instance is running with the correct name tag.

**Document:** How does Terraform know the S3 bucket already exists and only the EC2 instance needs to be created?
- Terraform keeps track of the resources it manages in a state file (usually `terraform.tfstate`). When you run `terraform plan` or `terraform apply`, it compares the desired state defined in your configuration files with the actual state of resources in AWS. Since the S3 bucket was created in the previous step, Terraform recognizes that it already exists and only plans to create the new EC2 instance.

---

### Task 5: Understand the State File
Terraform tracks everything it creates in a state file. Time to inspect it.

1. Open `terraform.tfstate` in your editor -- read the JSON structure
2. Run these commands and document what each returns:
```bash
terraform show                          # Human-readable view of current state
terraform state list                    # List all resources Terraform manages
terraform state show aws_s3_bucket.<name>   # Detailed view of a specific resource
terraform state show aws_instance.<name>
```
1. `terraform show`
- This command provides a human-readable summary of the current state of all resources managed by Terraform. It shows the attributes and values of each resource.

2. `terraform state list`
- This command lists all the resources that Terraform is currently managing in the state file. It shows the resource type and name for each resource.

![task5](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/960c33012bc8f51e97664aeca7640d780542ad4c/2026/day-61/images/task%205.JPG)

3. `terraform state show aws_s3_bucket`
- This command shows detailed information about the specific S3 bucket resource managed by Terraform, including its attributes and current state.
```bash
terraform state show aws_s3_bucket.My_bucket
```
![task5.1](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/960c33012bc8f51e97664aeca7640d780542ad4c/2026/day-61/images/task%205.1.JPG)

4. `terraform state show aws_instance`
- This command shows detailed information about the specific EC2 instance resource managed by Terraform, including its attributes and current state.
```bash
terraform state show aws_instance.ec2
```
![task5.2](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/960c33012bc8f51e97664aeca7640d780542ad4c/2026/day-61/images/task%205.2.JPG)

---
1. What information does the state file store about each resource?
- The state file stores the resource type, name, attributes (like IDs, ARNs, configuration values), and metadata about when it was created or modified. It also tracks dependencies between resources.
2. Why should you never manually edit the state file?
- Manually editing the state file can lead to inconsistencies and corruption. Terraform relies on the state file to accurately track resources, and any manual changes can cause Terraform to lose track of resources or make incorrect decisions during planning and applying.
3. Why should the state file not be committed to Git?
- The state file contains sensitive information such as resource IDs, ARNs, and potentially secrets. Committing it to Git can expose this information to unauthorized users. Additionally, the state file can change frequently, leading to merge conflicts if multiple team members are working on the same infrastructure. It's best to use remote state storage (like S3) for collaboration.
---
### Task 6: Modify, Plan, and Destroy
1. Change the EC2 instance tag from `"TerraWeek-Day1"` to `"TerraWeek-Modified"` in your `main.tf`

2. Run `terraform plan` and read the output carefully:
   - What do the `~`, `+`, and `-` symbols mean?
      
      `~` Resource will be `updated in-place`

      `+` Resource will be `created`
      
      `-` Resource will be `destroyed`
      
      

   - Is this an in-place update or a destroy-and-recreate?
      - Changing the EC2 tag results in a `~ (in-place update)

![task6](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/960c33012bc8f51e97664aeca7640d780542ad4c/2026/day-61/images/task%206.JPG)

3. Apply the change
```bash
terraform apply
```
4. Verify the tag changed in the AWS console

![task6.1](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/960c33012bc8f51e97664aeca7640d780542ad4c/2026/day-61/images/task%206.1.JPG)

5. Finally, destroy everything:
```bash
terraform destroy
```
6. Verify in the AWS console -- both the S3 bucket and EC2 instance should be gone

![task6.2](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/960c33012bc8f51e97664aeca7640d780542ad4c/2026/day-61/images/task%206.2.JPG)

![task6.3](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/960c33012bc8f51e97664aeca7640d780542ad4c/2026/day-61/images/task%206.3.JPG)

---
## Documentation
### What is IaC (Infrastructure as Code)?
Infrastructure as Code (IaC) is the practice of managing and provisioning computing infrastructure through machine-readable configuration files rather than manual processes. It allows developers and operations teams to define, deploy, and manage infrastructure in a consistent and repeatable way using code.
### Terraform Commands
- `terraform init`: Initializes a Terraform working directory by downloading necessary provider plugins and setting up the environment.
- `terraform plan`: Creates an execution plan, showing what actions Terraform will take to achieve the desired state defined in the configuration files.
- `terraform apply`: Applies the changes required to reach the desired state of the configuration. It creates, updates, or destroys resources as needed.
- `terraform destroy`: Destroys all resources managed by the current configuration, effectively tearing down the infrastructure.
- `terraform show`: Displays the current state in a readable format
- `terraform state list`: Lists all resources currently managed in the state file.
- `terraform state show <resource>`: Shows detailed information about a specific resource in the state file.

### What the state file contains and why it matters
The Terraform state file (`terraform.tfstate`) contains a JSON representation of all the resources that Terraform manages, including their current attributes, IDs, and metadata. It is crucial for Terraform to track the state of resources to determine what changes need to be made when you run `terraform plan` or `terraform apply`. The state file allows Terraform to know what resources exist, their current configuration, and how they relate to each other. It should be kept secure and not manually edited or committed to version control due to sensitive information and potential for corruption.

**What it contains:**
- Resource types and names
- Resource attributes (IDs, ARNs, configuration values)
- Metadata about when resources were created or modified

**Why it matters:**
- It allows Terraform to track and manage resources effectively
- It ensures consistency and prevents configuration drift
- It enables collaboration when stored in remote backends (like S3)

