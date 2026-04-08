# Day 66 -- Provision an EKS Cluster with Terraform Modules

## Overview

Today I provisioned a fully functional AWS EKS (Elastic Kubernetes Service) cluster using Terraform modules.

Instead of manually setting up Kubernetes like before, everything was:

Automated
Repeatable
Destroyable

This is how real DevOps teams manage Kubernetes infrastructure.

## complete file structure and key config files
```
terraform-eks/
│
├── .terraform/                # Terraform cache (auto-generated)
├── .gitignore
├── .terraform.lock.hcl       # Provider lock file
│
├── k8s/                      # Kubernetes manifests (post-EKS setup)
│   ├── nginx-deployment.yaml
│
├── eks.tf                    # EKS module call
├── vpc.tf                    # VPC module call
├── providers.tf              # Provider and backend config
├── variables.tf              # All input variables
├── terraform.tfvars          # Variable values
├── outputs.tf                # Cluster outputs
```

## Challenge Tasks

### Task 1: Project Setup
Create a new project directory with proper file structure:

```
terraform-eks/
  providers.tf        # Provider and backend config
  vpc.tf              # VPC module call
  eks.tf              # EKS module call
  variables.tf        # All input variables
  outputs.tf          # Cluster outputs
  terraform.tfvars    # Variable values
```

In `providers.tf`:
1. Pin the AWS provider to `~> 5.0`
2. Pin the Kubernetes provider (you will need it later)
3. Set your region

In `variables.tf`, define:
- `region` (string)
- `cluster_name` (string, default: `"terraweek-eks"`)
- `cluster_version` (string, default: `"1.31"`)
- `node_instance_type` (string, default: `"t3.medium"`)
- `node_desired_count` (number, default: `2`)
- `vpc_cidr` (string, default: `"10.0.0.0/16"`)

---

### Task 2: Create the VPC with Registry Module
EKS requires a VPC with both public and private subnets across multiple availability zones.

In `vpc.tf`, use the `terraform-aws-modules/vpc/aws` module:
1. CIDR: `var.vpc_cidr`
2. At least 2 availability zones
3. 2 public subnets and 2 private subnets
4. Enable NAT gateway (single NAT to save cost): `enable_nat_gateway = true`, `single_nat_gateway = true`
5. Enable DNS hostnames: `enable_dns_hostnames = true`
6. Add the required EKS tags on subnets:
```hcl
public_subnet_tags = {
  "kubernetes.io/role/elb" = 1
}

private_subnet_tags = {
  "kubernetes.io/role/internal-elb" = 1
}
```

Run `terraform init` and `terraform plan` to verify the VPC config before moving on.

![task2](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/93c8d6ed4bc5e4c052e163e00c1db81898c514a6/2026/day-66/images/task%202.jpg)

![task2.1](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/93c8d6ed4bc5e4c052e163e00c1db81898c514a6/2026/day-66/images/task%202.1.jpg)

**Document:** Why does EKS need both public and private subnets?
EKS uses public subnets for load balancers and private subnets for worker nodes. The subnet tags help EKS identify which subnets to use for which purpose.

- Private subnets: run your EKS nodes/pods securely (no direct internet access)
- Public subnets: host internet-facing load balancers

What do the subnet tags do?
The subnet tags (`kubernetes.io/role/elb` and `kubernetes.io/role/internal-elb`) are used by EKS to automatically discover and use the correct subnets for provisioning load balancers and worker nodes.

- `"kubernetes.io/role/elb"` tells AWS to use these public subnets for external load balancers
- `"kubernetes.io/role/internal-elb"` tells AWS to use these private subnets for internal load balancers


---

### Task 3: Create the EKS Cluster with Registry Module
In `eks.tf`, use the `terraform-aws-modules/eks/aws` module:

```hcl
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  cluster_endpoint_public_access = true

  eks_managed_node_groups = {
    terraweek_nodes = {
      ami_type       = "AL2_x86_64"
      instance_types = [var.node_instance_type]

      min_size     = 1
      max_size     = 3
      desired_size = var.node_desired_count
    }
  }

  tags = {
    Environment = "dev"
    Project     = "TerraWeek"
    ManagedBy   = "Terraform"
  }
}
```

Run:
```bash
terraform init      # Download EKS module and its dependencies
terraform plan      # Review -- this will create 30+ resources
```
![task3](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/93c8d6ed4bc5e4c052e163e00c1db81898c514a6/2026/day-66/images/task%203.jpg)

![task3.1](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/93c8d6ed4bc5e4c052e163e00c1db81898c514a6/2026/day-66/images/task%203.1.jpg)

![task3.2](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/93c8d6ed4bc5e4c052e163e00c1db81898c514a6/2026/day-66/images/task%203.2.jpg)

Review the plan carefully before applying. You should see: EKS cluster, IAM roles, node group, security groups, and more.

---

### Task 4: Apply and Connect kubectl
1. Apply the config:
```bash
terraform apply
```
![task4](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/93c8d6ed4bc5e4c052e163e00c1db81898c514a6/2026/day-66/images/task%204.jpg)

![task4.1](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/93c8d6ed4bc5e4c052e163e00c1db81898c514a6/2026/day-66/images/task%204.1.jpg)

![task4.3](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/93c8d6ed4bc5e4c052e163e00c1db81898c514a6/2026/day-66/images/task%204.3.jpg)


This will take 10-15 minutes. EKS cluster creation is slow -- be patient.

2. Add outputs in `outputs.tf`:
```hcl
output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_region" {
  value = var.region
}
```


3. Update your kubeconfig:
```bash
aws eks update-kubeconfig --name terraweek-eks --region <your-region>
```

4. Verify:
```bash
kubectl get nodes
kubectl get pods -A
kubectl cluster-info
```
![task4.5](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/93c8d6ed4bc5e4c052e163e00c1db81898c514a6/2026/day-66/images/task%204.5.jpg)

![task4.6](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/93c8d6ed4bc5e4c052e163e00c1db81898c514a6/2026/day-66/images/task%204.6.jpg)

**Verify:** Do you see 2 nodes in `Ready` state? Can you see the kube-system pods running?

- Yes.

![task4.9](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/93c8d6ed4bc5e4c052e163e00c1db81898c514a6/2026/day-66/images/task%204.9.jpg)

**Cluster**

![task4.10](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/93c8d6ed4bc5e4c052e163e00c1db81898c514a6/2026/day-66/images/task%204.10.jpg)

**Security Group**

![task4.11](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/93c8d6ed4bc5e4c052e163e00c1db81898c514a6/2026/day-66/images/task%204.11.jpg)

**Elastic IP**

![task4.12](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/93c8d6ed4bc5e4c052e163e00c1db81898c514a6/2026/day-66/images/task%204.12.jpg)

**VPC**

![task4.13](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/93c8d6ed4bc5e4c052e163e00c1db81898c514a6/2026/day-66/images/task%204.13.jpg)

**Auto Scaling Groups**

![task4.15](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/93c8d6ed4bc5e4c052e163e00c1db81898c514a6/2026/day-66/images/task%204.15.jpg)

---
### Task 5: Deploy a Workload on the Cluster
Your Terraform-provisioned cluster is live. Deploy something on it.

1. Create a file `k8s/nginx-deployment.yaml`:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-terraweek
  labels:
    app: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  type: LoadBalancer
  selector:
    app: nginx
  ports:
  - port: 80
    targetPort: 80
```

2. Apply:
```bash
kubectl apply -f k8s/nginx-deployment.yaml
```

3. Wait for the LoadBalancer to get an external IP:
```bash
kubectl get svc nginx-service -w
```
![task5](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/93c8d6ed4bc5e4c052e163e00c1db81898c514a6/2026/day-66/images/task%205.jpg)

4. Access the Nginx page via the LoadBalancer URL

5. Verify the full picture:
```bash
kubectl get nodes
kubectl get deployments
kubectl get pods
kubectl get svc
```
![task4.14](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/93c8d6ed4bc5e4c052e163e00c1db81898c514a6/2026/day-66/images/task%204.14.jpg)

**Verify:** Can you access the Nginx welcome page through the LoadBalancer URL?
- Yes.

![task5.1](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/93c8d6ed4bc5e4c052e163e00c1db81898c514a6/2026/day-66/images/task%205.1.jpg)

---

### Task 6: Destroy Everything
This is the most important step. EKS clusters cost money. Clean up completely.

1. First, remove the Kubernetes resources (so the AWS LoadBalancer gets deleted):
```bash
kubectl delete -f k8s/nginx-deployment.yaml
```
![task6](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/93c8d6ed4bc5e4c052e163e00c1db81898c514a6/2026/day-66/images/task%206.jpg)

2. Wait for the LoadBalancer to be fully removed (check EC2 > Load Balancers in AWS console)

3. Destroy all Terraform resources:
```bash
terraform destroy
```
![task6.1](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/93c8d6ed4bc5e4c052e163e00c1db81898c514a6/2026/day-66/images/task%206.1.jpg)

This will take 10-15 minutes.

4. Verify in the AWS console:
   - EKS clusters: empty
   - EC2 instances: no node group instances
   - VPC: the terraweek VPC should be gone
   - NAT Gateways: deleted
   - Elastic IPs: released

**Verify:** Is your AWS account completely clean? No leftover resources?
- Yes, my account is compleately clean.

---

### How many resources Terraform created in total
- The VPC module created 10+ resources (VPC, subnets, route tables, IGW, etc.)
- The EKS module created 30+ resources (EKS cluster, IAM roles, node group, security groups, etc.)
  - 57

### The destroy process and verification
- The destroy process took around 15 minutes to complete. EKS cluster deletion is slow.
- After destroy, I verified in the AWS console that there were no EKS clusters, no EC2 instances, no VPCs, no NAT Gateways, and no Elastic IPs left. My account is completely clean.

![task6.2](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/93c8d6ed4bc5e4c052e163e00c1db81898c514a6/2026/day-66/images/task%206.2.jpg)

![task6.3](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/93c8d6ed4bc5e4c052e163e00c1db81898c514a6/2026/day-66/images/task%206.3.jpg)

---

### Switch back to kind cluster
```bash
kubectl config get-contexts
```
```bash
kubectl config use-context kind-devops
```
```bash
kubectl get nodes
```
![task7](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/93c8d6ed4bc5e4c052e163e00c1db81898c514a6/2026/day-66/images/task%207.jpg)

---

### Reflection: compare this to manually setting up a cluster with kind/minikube (Day 50)
- The Terraform approach is more complex to set up initially, but it provides a fully automated, repeatable, and destroyable infrastructure. I can version control my cluster config and easily recreate it in any environment.
- The kind/minikube approach is simpler and faster for local development, but it doesn't represent real cloud infrastructure and isn't suitable for production workloads. It's more of a learning tool than a real solution.


| Local cluster	| Production-grade cluster |
|----------|--------|
| Kind/Minikube	| EKS with Terraform |
| Quick setup (minutes)	| Complex setup (hours) |
| Not cloud-native	| Fully cloud-native |
| Not scalable	| Scalable with node groups |
| Not highly available	| Highly available across AZs |
| Run on locally | Run on Cloud |


### Challenges Faced and Fixes
- Challenge: EKS creation is slow, and I had to wait 15 minutes for the cluster to be ready.
  - Fix: I used this time to review the Terraform code and understand all the resources being created.
- Challenge: I got `Unauthorized` errors when trying to access the cluster with kubectl.
    - Fix: I re-ran the `aws eks update-kubeconfig` command to refresh my kubeconfig with the new cluster credentials.

---
## Hints
- EKS creation takes 10-15 minutes, destruction takes about the same -- plan your time
- Always delete Kubernetes LoadBalancer services before `terraform destroy`, otherwise the ELB will block VPC deletion
- If `terraform destroy` gets stuck, check for leftover ENIs or security groups in the VPC
- `t3.medium` is the minimum recommended instance type for EKS nodes
- The EKS module creates IAM roles automatically -- you don't need to create them manually
- If you see `Unauthorized` with kubectl, re-run the `aws eks update-kubeconfig` command
- Use `kubectl get events --sort-by=.metadata.creationTimestamp` to debug pod issues
- Cost warning: NAT Gateway charges ~$0.045/hour. Destroy when done.
---


