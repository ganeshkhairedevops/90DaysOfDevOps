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

