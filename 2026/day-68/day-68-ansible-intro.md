# Day 68 -- Introduction to Ansible and Inventory Setup
## 📌 Overview

Today I explored **Ansible**, a powerful configuration management tool used to automate server setup, configuration, and maintenance.

While Terraform provisions infrastructure, Ansible ensures systems are configured and maintained in a consistent state.

---

## Challenge Tasks

### Task 1: Understand Ansible
I researched and took notes on the following topics:
1. What is configuration management? Why do we need it?
    
    - Configuration management is the process of maintaining systems in a **desired, consistent, and repeatable state**.

- Avoid manual errors
- Ensure consistency across environments
- Reduce configuration drift
- Enable automation at scale

2. How is Ansible different from Chef, Puppet, and Salt?
- Ansible is **agentless** and uses SSH, while Chef, Puppet, and Salt require agents installed on managed nodes.
- Ansible uses **YAML** for playbooks, which is more human-readable than the Ruby DSL used by Chef and Puppet.
- Ansible has a simpler architecture and is easier to learn for beginners.
3. What does "agentless" mean? How does Ansible connect to managed nodes?
- "Agentless" means Ansible does not require any software agents to be installed on the managed nodes.
- Ansible connects to managed nodes using **SSH** (or WinRM for Windows), allowing it to execute tasks remotely without additional software.
4. Draw or describe the Ansible architecture:
- **Control Node**: The machine where Ansible is installed and run (e.g., my laptop).
- **Managed Nodes**: The servers that Ansible configures (e.g., my EC2 instances).
- **Inventory**: A file that lists the managed nodes and groups them logically.
- **Modules**: Reusable units of work that Ansible executes (e.g., installing a package, copying a file).
- **Playbooks**: YAML files that define a series of tasks to be executed on specified hosts.
---

### Task 2: Set Up Your Lab Environment
I provisioned 3 EC2 instances using Terraform with the following specifications:
- Amazon Linux 2
- `t2.micro` instance type
- A security group allowing SSH (port 22)
- A key pair for SSH access
I labeled the instances as follows:
- **Instance 1:** web server
- **Instance 2:** app server
- **Instance 3:** db server

![task2.1](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/391e75ef9653de68a0677e0840be8100ae214bf2/2026/day-68/images/task2.1.JPG)

I verified SSH access to each instance from my control node:
```bash
ssh -i ~/your-key.pem ec2-user@<public-ip-1>
ssh -i ~/your-key.pem ec2-user@<public-ip-2>
ssh -i ~/your-key.pem ec2-user@<public-ip-3>
```
![task2](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/391e75ef9653de68a0677e0840be8100ae214bf2/2026/day-68/images/task%202.JPG)

![task2.2](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/391e75ef9653de68a0677e0840be8100ae214bf2/2026/day-68/images/task%202.2.jpg)

---
### Task 3: Install Ansible
Install Ansible on your **control node** (your laptop or one dedicated EC2 instance):

```bash
# macOS
brew install ansible

# Ubuntu/Debian
sudo apt update
sudo apt install ansible -y

# Amazon Linux / RHEL
sudo yum install ansible -y
# or
pip3 install ansible

# Verify
ansible --version
```

Confirm the output shows the Ansible version, config file path, and Python version.

![task3](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/391e75ef9653de68a0677e0840be8100ae214bf2/2026/day-68/images/task%203.jpg)

**Document:** On which machine did you install Ansible? Why is it only needed on the control node?

I installed Ansible on my **laptop** (control node). Ansible is only needed on the control node because it uses SSH to connect to the managed nodes and execute tasks remotely. The managed nodes do not require any software installation, making Ansible an agentless tool.
- Ansible is installed on the **control node** because it runs playbooks from there and connects to other servers via SSH.
- Target machines only need SSH and Python—no Ansible installation is required.

---

### Task 4: Create Your Inventory File
The inventory tells Ansible which servers to manage. Create a project directory and your first inventory:

```bash
mkdir ansible-practice && cd ansible-practice
```

Create a file called `inventory.ini`:
```ini
[web]
web-server ansible_host=<PUBLIC_IP_1>

[app]
app-server ansible_host=<PUBLIC_IP_2>

[db]
db-server ansible_host=<PUBLIC_IP_3>

[all:vars]
ansible_user=ec2-user
ansible_ssh_private_key_file=~/your-key.pem
```

Verify Ansible can reach all hosts:
```bash
ansible all -i inventory.ini -m ping
```

You should see green `SUCCESS` with `"ping": "pong"` for each host.

![task4](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/391e75ef9653de68a0677e0840be8100ae214bf2/2026/day-68/images/task%204.JPG)

**Troubleshoot:** If ping fails:
- Check the SSH key path and permissions (`chmod 400 your-key.pem`)
- Check the security group allows SSH from your IP
- Check the `ansible_user` matches your AMI (ec2-user for Amazon Linux, ubuntu for Ubuntu)

---

### Task 5: Run Ad-Hoc Commands
Ad-hoc commands let you run quick one-off tasks without writing a playbook.

1. **Check uptime on all servers:**
```bash
ansible all -i inventory.ini -m command -a "uptime"
```
![task5](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/391e75ef9653de68a0677e0840be8100ae214bf2/2026/day-68/images/task%205.JPG)

2. **Check free memory on web servers only:**
```bash
ansible web -i inventory.ini -m command -a "free -h"
```
![task5.1](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/391e75ef9653de68a0677e0840be8100ae214bf2/2026/day-68/images/task%205.1.JPG)

3. **Check disk space on all servers:**
```bash
ansible all -i inventory.ini -m command -a "df -h"
```
![task5.2](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/391e75ef9653de68a0677e0840be8100ae214bf2/2026/day-68/images/task%205.2.JPG)

4. **Install a package on the web group:**
```bash
ansible web -i inventory.ini -m yum -a "name=git state=present" --become
```
(Use `apt` instead of `yum` if running Ubuntu)

![task5.3](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/391e75ef9653de68a0677e0840be8100ae214bf2/2026/day-68/images/task%205.3.JPG)

5. **Copy a file to all servers:**
```bash
echo "Hello from Ansible" > hello.txt
ansible all -i inventory.ini -m copy -a "src=hello.txt dest=/tmp/hello.txt"
```
![task5.4](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/391e75ef9653de68a0677e0840be8100ae214bf2/2026/day-68/images/task%205.4.JPG)

6. **Verify the file was copied:**
```bash
ansible all -i inventory.ini -m command -a "cat /tmp/hello.txt"
```
![task5.5](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/391e75ef9653de68a0677e0840be8100ae214bf2/2026/day-68/images/task%205.5.JPG)

**Document:** What does `--become` do? When do you need it?
`--become` allows you to run tasks with elevated privileges (e.g., as root). You need it when the task requires permissions that the default user does not have, such as installing packages or modifying system files.

---

### Task 6: Explore Inventory Groups and Patterns
1. **Create a group of groups** -- add this to your `inventory.ini`:
```ini
[application:children]
web
app

[all_servers:children]
application
db
```

2. Run commands against different groups:
```bash
ansible application -i inventory.ini -m ping     # web + app servers
ansible db -i inventory.ini -m ping               # only db server
ansible all_servers -i inventory.ini -m ping      # everything
```
![task6](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/391e75ef9653de68a0677e0840be8100ae214bf2/2026/day-68/images/task%206.JPG)

3. **Use patterns:**
```bash
ansible 'web:app' -i inventory.ini -m ping        # OR: web or app
ansible 'all:!db' -i inventory.ini -m ping        # NOT: all except db
```
![task6.1](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/391e75ef9653de68a0677e0840be8100ae214bf2/2026/day-68/images/task%206.1.JPG)

4. **Create an `ansible.cfg`** to avoid typing `-i inventory.ini` every time:
```ini
[defaults]
inventory = inventory.ini
host_key_checking = False
remote_user = ec2-user
private_key_file = ~/your-key.pem
```
Now you can simply run:
```bash
ansible all -m ping
```

**Verify:** Does `ansible all -m ping` work without specifying the inventory file?
Yes, after creating the `ansible.cfg` file with the inventory path specified, running `ansible all -m ping` works without needing to specify the inventory file each time.

![task6.2](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/391e75ef9653de68a0677e0840be8100ae214bf2/2026/day-68/images/task%206.2.JPG)

---
## Hints
- Use `ansible-doc -l` to list all available modules.
- Use `ansible-doc <module_name>` to get detailed information about a specific module.
- Remember to set correct permissions on your SSH key (`chmod
    400 your-key.pem`) to avoid SSH errors.
- If you encounter SSH connection issues, check your security group settings and ensure your IP is allowed to connect on port 22.
- Use `ansible all -m setup` to gather facts about your servers, which can be useful for debugging and writing playbooks later on.
---
