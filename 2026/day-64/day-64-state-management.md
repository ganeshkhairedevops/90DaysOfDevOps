# Day 64 -- Terraform State Management and Remote Backends
## Overview
Terraform state is the most critical component of infrastructure management. It acts as the **source of truth** that maps Terraform configuration to real-world resources.

---
## Challenge Tasks

### Task 1: Inspect Your Current State
Use your Day 63 config (or create a small config with a VPC and EC2 instance). Apply it and then explore the state:

```bash
terraform show                                    # Full state in human-readable format
terraform state list                              # All resources tracked by Terraform
terraform state show aws_instance.<name>          # Every attribute of the instance
terraform state show aws_vpc.<name>               # Every attribute of the VPC
```

Answer:
1. How many resources does Terraform track?
    - Terraform track 7 resources (Data sources are read-only and not counted)

2. What attributes does the state store for an EC2 instance? (hint: way more than what you defined)
     - `ami`,`instance_type`,`tags`,`key_name`

    - `private_ip`, `public_ip`, `private_dns`, `public_dns`, `subnet_id`, `vpc_security_group_ids`, `primary_network_interface_id`

    - `root_block_device` ,`volume_id`, `volume_size`, `volume_type`, `delete_on_termination`
3. Open `terraform.tfstate` in an editor -- find the `serial` number. What does it represent?
    - The `serial` number is a unique identifier that increments with each change to the state. It helps Terraform track the version of the state file and detect conflicts when multiple users are working on the same infrastructure.

![task1](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/2a3720e7cedb71cccafafd3ff92dcc8ab8e86cd5/2026/day-64/images/task%201.JPG)

![task1.1](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/2a3720e7cedb71cccafafd3ff92dcc8ab8e86cd5/2026/day-64/images/task%201.1.JPG)

---
### Task 2: Set Up S3 Remote Backend
Storing state locally is dangerous -- one deleted file and you lose everything. Time to move it to S3.

1. First, create the backend infrastructure (do this manually or in a separate Terraform config):
```bash
# Create S3 bucket for state storage
aws s3api create-bucket \
  --bucket terraweek-state-ganeshkhaire \
  --region us-east-1 \
  --create-bucket-configuration LocationConstraint=us-east-1

# Enable versioning (so you can recover previous state)
aws s3api put-bucket-versioning \
  --bucket terraweek-state-ganeshkhaire \
  --versioning-configuration Status=Enabled

# Create DynamoDB table for state locking
aws dynamodb create-table \
  --table-name terraweek-state-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region us-east-1
```
![task2](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/2a3720e7cedb71cccafafd3ff92dcc8ab8e86cd5/2026/day-64/images/task%202.JPG)

![task2.1](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/2a3720e7cedb71cccafafd3ff92dcc8ab8e86cd5/2026/day-64/images/task%202.1.JPG)

create-table

![task2.2](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/2a3720e7cedb71cccafafd3ff92dcc8ab8e86cd5/2026/day-64/images/task%202.2.JPG)

2. Add the backend block to your Terraform config:
Create `backend.tf:`
```hcl
terraform {
  backend "s3" {
    bucket         = "terraweek-state-ganeshkhaire"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraweek-state-lock"
    encrypt        = true
  }
}
```

3. Run:
```bash
terraform init
```
Terraform will ask: "Do you want to copy existing state to the new backend?" -- say yes.

![task2.3](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/2a3720e7cedb71cccafafd3ff92dcc8ab8e86cd5/2026/day-64/images/task%202.3.JPG)


4. Verify:
    - Check the S3 bucket -- you should see `dev/terraform.tfstate`
    ![task2.4](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/2a3720e7cedb71cccafafd3ff92dcc8ab8e86cd5/2026/day-64/images/task%202.4.JPG)
    
    - Your local `terraform.tfstate` should now be empty or gone

        - Yes,it should be empty

    - Run `terraform plan` -- it should show no changes (state migrated correctly)
        - Yes, it should show no changes
    ![task2.5](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/2a3720e7cedb71cccafafd3ff92dcc8ab8e86cd5/2026/day-64/images/task%202.5.JPG)

---
### Task 3: Test State Locking
State locking prevents two people from running `terraform apply` at the same time and corrupting the state.

1. Open **two terminals** in the same project directory
2. In Terminal 1, run:
```bash
terraform apply
```
![task3](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/2a3720e7cedb71cccafafd3ff92dcc8ab8e86cd5/2026/day-64/images/task%203.JPG)

3. While Terminal 1 is waiting for confirmation, in Terminal 2 run:
```bash
terraform plan
```
4. Terminal 2 should show a **lock error** with a Lock ID

![task3.1](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/2a3720e7cedb71cccafafd3ff92dcc8ab8e86cd5/2026/day-64/images/task%203.1.JPG)

**Document:** What is the error message? Why is locking critical for team environments?
- The error message is: `Error acquiring the state lock: ConditionalCheckFailedException: The conditional request failed`
- Locking is critical for team environments because it prevents multiple users from making changes to the infrastructure at the same time, which can lead to conflicts and corruption of the state file. It ensures that only one user can apply changes to the infrastructure at a time, maintaining the integrity of the state and preventing potential issues.
5. After the test, if you get stuck with a stale lock:
```bash
terraform force-unlock <LOCK_ID>
```
---

### Task 4: Import an Existing Resource
Not everything starts with Terraform. Sometimes resources already exist in AWS and you need to bring them under Terraform management.

1. Manually create an S3 bucket in the AWS console -- name it `terraweek-import-test-ganeshkhaire`

![task4](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/2a3720e7cedb71cccafafd3ff92dcc8ab8e86cd5/2026/day-64/images/task%204.JPG)

2. Write a `resource "aws_s3_bucket"` block in your config for this bucket (just the bucket name, nothing else)
3. Import it:
```bash
terraform import aws_s3_bucket.imported terraweek-import-test-<yourname>

terraform import aws_s3_bucket.imported terraweek-import-test-ganeshkhaire
```
![task4.1](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/2a3720e7cedb71cccafafd3ff92dcc8ab8e86cd5/2026/day-64/images/task%204.1.JPG)

4. Run `terraform plan`:
   - If you see "No changes" -- the import was perfect
   - If you see changes -- your config does not match reality. Update your config to match, then plan again until you get "No changes"

5. Run `terraform state list` -- the imported bucket should now appear alongside your other resources

![task4.2](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/2a3720e7cedb71cccafafd3ff92dcc8ab8e86cd5/2026/day-64/images/task%204.2.JPG)

**Document:** What is the difference between `terraform import` and creating a resource from scratch?
- `terraform import` is used to bring existing resources that were created outside of Terraform under Terraform's management. It allows you to associate a real-world resource with a resource block in your Terraform configuration without actually creating a new resource. On the other hand, creating a resource from scratch involves defining a resource block in your Terraform configuration and then applying it, which results in Terraform creating the resource in the cloud provider.

`terraform import`
- Bring an existing resource (already in AWS, etc.) under Terraform management
- Updates the Terraform state file to track the resource
- `use case` Migrating manual or existing resources into Terraform
- `Example:`
    ```bash
    # Import an existing S3 bucket
    terraform import aws_s3_bucket.imported terraweek-import-test-ganeshkhaire
    ```

`Creating a Resource from Scratch`
- Terraform creates a new resource in the cloud
- Both state and actual resource are created by Terraform
- `use case` Standard workflow when starting from scratch
- `Example:`
    ```bash
    # Create a new S3 bucket from scratch
    resource "aws_s3_bucket" "new" {
    bucket = "terraweek-new-bucket"
    }

    ```
---

### Task 5: State Surgery -- mv and rm
Sometimes you need to rename a resource or remove it from state without destroying it in AWS.

1. **Rename a resource in state:**
```bash
terraform state list                              # Note the current resource names
terraform state mv aws_s3_bucket.imported aws_s3_bucket.logs_bucket
```
![task5.1](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/2a3720e7cedb71cccafafd3ff92dcc8ab8e86cd5/2026/day-64/images/task%205.1.JPG)

![task5](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/2a3720e7cedb71cccafafd3ff92dcc8ab8e86cd5/2026/day-64/images/task%205.JPG)

Update your `.tf` file to match the new name. Run `terraform plan` -- it should show no changes.

- `current resource name:` `aws_s3_bucket.imported`
- `after rename resource name:` `aws_s3_bucket.logs_bucket`


2. **Remove a resource from state (without destroying it):**
```bash
terraform state rm aws_s3_bucket.logs_bucket
```

![task5.2](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/2a3720e7cedb71cccafafd3ff92dcc8ab8e86cd5/2026/day-64/images/task%205.2.JPG)

Run `terraform plan` -- Terraform no longer knows about the bucket, but it still exists in AWS.

![task5.3](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/2a3720e7cedb71cccafafd3ff92dcc8ab8e86cd5/2026/day-64/images/task%205.3.JPG)

3. **Re-import it** to bring it back:
```bash
terraform import aws_s3_bucket.logs_bucket terraweek-import-test-ganeshkhaire
```
![task5.4](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/2a3720e7cedb71cccafafd3ff92dcc8ab8e86cd5/2026/day-64/images/task%205.4.JPG)

**Document:** When would you use `state mv` in a real project? When would you use `state rm`?
- `state mv` is used when you want to rename a resource in your Terraform configuration without destroying and recreating it. This is useful when you want to improve naming conventions or reorganize your resources without affecting the actual infrastructure.
- `state rm` is used when you want to remove a resource from Terraform's state management without deleting the actual resource in the cloud provider. This can be useful when you want to stop managing a resource with Terraform but still want it to exist in the cloud, or when you want to clean up your state file without affecting the real infrastructure.

---

### Task 6: Simulate and Fix State Drift
State drift happens when someone changes infrastructure outside of Terraform -- through the AWS console, CLI, or another tool.

1. Apply your full config so everything is in sync
2. Go to the **AWS console** and manually:
   - Change the Name tag of your EC2 instance to `"ManuallyChanged"`
   - Change the instance type if it's stopped (or add a new tag)

   ![task6](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/2a3720e7cedb71cccafafd3ff92dcc8ab8e86cd5/2026/day-64/images/task%206.JPG)

3. Run:
```bash
terraform plan
```
You should see a **diff** -- Terraform detects that reality no longer matches the desired state.

![task6.1](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/2a3720e7cedb71cccafafd3ff92dcc8ab8e86cd5/2026/day-64/images/task%206.1.JPG)

4. You have two choices:
   - **Option A:** Run `terraform apply` to force reality back to match your config (reconcile)
   - **Option B:** Update your `.tf` files to match the manual change (accept the drift)

5. Choose Option A -- apply and verify the tags are restored.

![task6.2](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/2a3720e7cedb71cccafafd3ff92dcc8ab8e86cd5/2026/day-64/images/task%206.2.JPG)

6. Run `terraform plan` again -- it should show "No changes." Drift resolved.

![task6.3](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/2a3720e7cedb71cccafafd3ff92dcc8ab8e86cd5/2026/day-64/images/task%206.3.JPG)

**Document:** How do teams prevent state drift in production?
- Teams prevent state drift in production by implementing strict access controls to the cloud provider's console, ensuring that all changes to infrastructure are made through Terraform and not manually. They often use CI/CD pipelines to automate the application of Terraform configurations, which helps maintain consistency and reduces the likelihood of manual changes. Additionally, teams may implement monitoring and alerting for any changes made outside of Terraform to quickly identify and address potential drift issues.

---

### Diagram: local state vs remote state setup

![Digram](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/2a3720e7cedb71cccafafd3ff92dcc8ab8e86cd5/2026/day-64/images/State%20Management.png)




        ┌──────────────────────┐
        │     LOCAL STAT       |
        └──────────────────────┘

        ┌──────────────────────┐
        │   Terraform CLI      │
        │ (on your machine)    │
        └─────────┬────────────┘
                  │
                  ▼
        ┌──────────────────────┐
        │ terraform.tfstate    │
        │ (local file)         │
        └─────────┬────────────┘
                  │
                  ▼
        ┌──────────────────────┐
        │   AWS Resources      │
        │ (EC2, VPC, etc.)     │
        └──────────────────────┘


⚠️ Problems:
- Single point of failure
- No locking
- Not team-friendly
- Easy to lose/corrupt


============================================================


       ┌──────────────────────────┐
       │       REMOTESTATE        │
       └──────────────────────────┘

        ┌──────────────────────┐
        │   Terraform CLI      │
        │ (any team member)    │
        └─────────┬────────────┘
                  │
                  ▼
        ┌──────────────────────────────┐
        │      S3 Bucket               │
        │ terraform.tfstate (remote)   │
        │ + versioning enabled         │
        └─────────┬────────────────────┘
                  │
                  ▼
        ┌──────────────────────────────┐
        │ DynamoDB Table               │
        │ State Lock (LockID)          │
        └─────────┬────────────────────┘
                  │
                  ▼
        ┌──────────────────────┐
        │   AWS Resources      │
        │ (EC2, VPC, etc.)     │
        └──────────────────────┘


✅ Benefits:
- Shared state (team access)
- State locking (no conflicts)
- Versioning (recovery)
- Safer and production-ready

---
## Steps for terraform import and Result
1. **Created an S3 bucket manually** in AWS Console
  - Bucket name: `terraweek-import-test-ganeshkhaire`
2. **Added Terraform resource block** in my configuration:
```hcl
resource "aws_s3_bucket" "imported" {
  bucket = "terraweek-import-test-ganeshkhaire"
}
```
(just the bucket name, nothing else)

3. **Imported the existing bucket** into Terraform state:
```bash
terraform import aws_s3_bucket.imported terraweek-import-test-ganeshkhaire
```
![task4.1](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/a7193eac1d912138268382e772e66400e728433f/2026/day-64/images/task%204.1.JPG)

4. **Run `terraform plan`** to check for changes:
   - Result: "No changes" -- the import was perfect, and now Terraform is managing the existing bucket without trying to recreate it.

5. Verified the state:

```bash
terraform state list
```
![task4.2](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/a7193eac1d912138268382e772e66400e728433f/2026/day-64/images/task%204.2.JPG)

The imported resource appeared in the state file

- Result: The imported bucket `aws_s3_bucket.imported` now appears in the state alongside other resources, confirming that it is successfully tracked by Terraform. 

6. Checked for drift:
```bash
terraform plan
```
- Result: "No changes" -- the imported resource matches the actual state in AWS, so there is no drift detected.

