# Day 70 -- Variables, Facts, Conditionals and Loops

## Overview
Today I made my Ansible playbooks dynamic using variables, facts, conditionals, and loops.
## Variables
Variables are used to store values that can be reused throughout the playbook. They can be defined in various places, such as in the playbook itself, in inventory files, or in separate variable files. Variables can be accessed using the `{{ variable_name }}` syntax.
## Facts
Facts are pieces of information about the target hosts that Ansible gathers automatically. They can include details about the operating system, network interfaces, and hardware. Facts can be accessed using the `{{ ansible_facts }}` variable.
## Conditionals
Conditionals allow you to execute tasks based on certain conditions. You can use the `when` keyword to specify a condition that must be met for a task to run. For example, you can check if a variable is defined or if a fact has a specific value.
## Loops
Loops allow you to repeat a task for a list of items. You can use the `with_items` keyword to specify a list of items that the task should iterate over. For example, you can loop through a list of packages to install them on the target hosts.

---

## Challenge Tasks

### Task 1: Variables in Playbooks
Create `variables-demo.yml`:

```yaml
---
- name: Variable demo
  hosts: all
  become: true

  vars:
    app_name: terraweek-app
    app_port: 8080
    app_dir: "/opt/{{ app_name }}"
    packages:
      - git
      - curl
      - wget

  tasks:
    - name: Print app details
      debug:
        msg: "Deploying {{ app_name }} on port {{ app_port }} to {{ app_dir }}"

    - name: Create application directory
      file:
        path: "{{ app_dir }}"
        state: directory
        mode: '0755'

    - name: Install required packages
      yum:
        name: "{{ packages }}"
        state: present
```

Run it and verify the variables resolve correctly.

![task1](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/341107d39b000534918e3e23105555ebd2edb809/2026/day-70/images/task%201.JPG)

Now, override a variable from the command line:
```bash
ansible-playbook variables-demo.yml -e "app_name=my-custom-app app_port=9090"
```

**Verify:** Does the CLI variable override the playbook variable?
-   yes

![task1.1](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/341107d39b000534918e3e23105555ebd2edb809/2026/day-70/images/task%201.1.JPG)

---
### Task 2: Using Facts
Variables should not live inside playbooks. Move them to dedicated files.

Create this structure:
```
ansible-practice/
  inventory.ini
  ansible.cfg
  group_vars/
    all.yml
    web.yml
    db.yml
  host_vars/
    web-server.yml
  playbooks/
    site.yml
```

**`group_vars/all.yml`** -- applies to every host:
```yaml
---
ntp_server: pool.ntp.org
app_env: development
common_packages:
  - vim
  - htop
  - tree
```

**`group_vars/web.yml`** -- applies only to the web group:
```yaml
---
http_port: 80
max_connections: 1000
web_packages:
  - nginx
```

**`group_vars/db.yml`** -- applies only to the db group:
```yaml
---
db_port: 3306
db_packages:
  - mysql-server
```

**`host_vars/web-server.yml`** -- applies only to this specific host:
```yaml
---
max_connections: 2000
custom_message: "This is the primary web server"
```

Write a playbook `site.yml` that uses these variables:
```yaml
---
- name: Apply common config
  hosts: all
  become: true
  tasks:
    - name: Install common packages
      yum:
        name: "{{ common_packages }}"
        state: present
    - name: Show environment
      debug:
        msg: "Environment: {{ app_env }}"

- name: Configure web servers
  hosts: web
  become: true
  tasks:
    - name: Show web config
      debug:
        msg: "HTTP port: {{ http_port }}, Max connections: {{ max_connections }}"
    - name: Show host-specific message
      debug:
        msg: "{{ custom_message }}"
```

Run it and observe which variables apply to which hosts.

![task2](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/341107d39b000534918e3e23105555ebd2edb809/2026/day-70/images/task%202.JPG)

**Document:** What is the variable precedence? (hint: host_vars > group_vars > playbook vars, and `-e` overrides everything)

The variable precedence in Ansible is as follows:
1. Command line variables (`-e`) - These have the highest precedence and will override all other variables.
2. Host variables (`host_vars`) - Variables defined for specific hosts will override group variables and playbook variables.
3. Group variables (`group_vars`) - Variables defined for groups of hosts will override playbook variables but can be overridden by host variables.
4. Playbook variables - Variables defined within the playbook itself have the lowest precedence and can be overridden by both group and host variables, as well as command line variables.
---

### Task 3: Ansible Facts -- Gathering System Information
Ansible automatically collects "facts" about each managed node -- OS, IP, memory, CPU, disks, and hundreds more.

1. **See all facts for a host:**
```bash
ansible web-server -m setup
```
![task3](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/341107d39b000534918e3e23105555ebd2edb809/2026/day-70/images/task%203.JPG)

2. **Filter specific facts:**
```bash
ansible web-server -m setup -a "filter=ansible_os_family"
ansible web-server -m setup -a "filter=ansible_distribution*"
ansible web-server -m setup -a "filter=ansible_memtotal_mb"
ansible web-server -m setup -a "filter=ansible_default_ipv4"
```
![task3.1](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/341107d39b000534918e3e23105555ebd2edb809/2026/day-70/images/task%203.1.JPG)

3. **Use facts in a playbook** -- create `facts-demo.yml`:
```yaml
---
- name: Facts demo
  hosts: all
  tasks:
    - name: Show OS info
      debug:
        msg: >
          Hostname: {{ ansible_hostname }},
          OS: {{ ansible_distribution }} {{ ansible_distribution_version }},
          RAM: {{ ansible_memtotal_mb }}MB,
          IP: {{ ansible_default_ipv4.address }}

    - name: Show all network interfaces
      debug:
        var: ansible_interfaces
```

Run it and observe the facts printed for each host.

![task3.2](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/341107d39b000534918e3e23105555ebd2edb809/2026/day-70/images/task%203.2.JPG)

**Document:** Name five facts you would use in real playbooks and why.
1. `ansible_os_family` - To determine the operating system family (e.g., RedHat, Debian) and apply OS-specific tasks.
2. `ansible_distribution` - To identify the specific Linux distribution (e.g., Ubuntu, CentOS) for more granular control over tasks.
3. `ansible_memtotal_mb` - To check the total memory of a host and make decisions based on resource availability.
4. `ansible_default_ipv4.address` - To retrieve the default IPv4 address of a host for network configuration or inventory purposes.
5. `ansible_processor` - To gather information about the CPU architecture and make decisions based on hardware capabilities.
---

### Task 4: Conditionals with when
Tasks should not always run on every host. Use `when` to control execution.

Create `conditional-demo.yml`:

```yaml
---
- name: Conditional tasks demo
  hosts: all
  become: true

  tasks:
    - name: Install Nginx (only on web servers)
      yum:
        name: nginx
        state: present
      when: "'web' in group_names"

    - name: Install MySQL (only on db servers)
      yum:
        name: mysql-server
        state: present
      when: "'db' in group_names"

    - name: Show warning on low memory hosts
      debug:
        msg: "WARNING: This host has less than 1GB RAM"
      when: ansible_memtotal_mb < 1024

    - name: Run only on Amazon Linux
      debug:
        msg: "This is an Amazon Linux machine"
      when: ansible_distribution == "Amazon"

    - name: Run only on Ubuntu
      debug:
        msg: "This is an Ubuntu machine"
      when: ansible_distribution == "Ubuntu"

    - name: Run only in production
      debug:
        msg: "Production settings applied"
      when: app_env == "production"

    - name: Multiple conditions (AND)
      debug:
        msg: "Web server with enough memory"
      when:
        - "'web' in group_names"
        - ansible_memtotal_mb >= 512

    - name: OR condition
      debug:
        msg: "Either web or app server"
      when: "'web' in group_names or 'app' in group_names"
```

Run it and observe which tasks are skipped on which hosts.
- Observation
    -   Nginx is only installed on web servers.
    -   MySQL is only installed on db servers.
    -   The low memory warning only appears on hosts with less than 1GB of RAM.


![task4](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/341107d39b000534918e3e23105555ebd2edb809/2026/day-70/images/task%204.JPG)

![task4.1](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/341107d39b000534918e3e23105555ebd2edb809/2026/day-70/images/task%204.1.JPG)

**Verify:** Are tasks correctly skipping on hosts that don't match the condition?
-   yes

---

### Task 5: Loops
Create `loops-demo.yml`:

```yaml
---
- name: Loops demo
  hosts: all
  become: true

  vars:
    users:
      - name: deploy
        groups: wheel
      - name: monitor
        groups: wheel
      - name: appuser
        groups: users

    directories:
      - /opt/app/logs
      - /opt/app/config
      - /opt/app/data
      - /opt/app/tmp

  tasks:
    - name: Create multiple users
      user:
        name: "{{ item.name }}"
        groups: "{{ item.groups }}"
        state: present
      loop: "{{ users }}"

    - name: Create multiple directories
      file:
        path: "{{ item }}"
        state: directory
        mode: '0755'
      loop: "{{ directories }}"

    - name: Install multiple packages
      yum:
        name: "{{ item }}"
        state: present
      loop:
        - git
        - curl
        - unzip
        - jq

    - name: Print each user created
      debug:
        msg: "Created user {{ item.name }} in group {{ item.groups }}"
      loop: "{{ users }}"
```

Run it and observe the loop output -- each iteration is shown separately.

![task5](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/341107d39b000534918e3e23105555ebd2edb809/2026/day-70/images/task%205.JPG)


**Document:** What is the difference between `loop` and the older `with_items`? (hint: `loop` is the modern recommended syntax)

The `loop` keyword is the modern recommended syntax for iterating over lists in Ansible playbooks, while `with_items` is the older syntax. The main differences are:
1. **Syntax**: `loop` uses a more straightforward syntax that is easier to read and write, while `with_items` can be more verbose.
2. **Functionality**: `loop` provides more features and flexibility, such as support for nested loops and better handling of complex data structures, whereas `with_items` is limited to simple lists.
3. **Performance**: `loop` is optimized for better performance and can handle larger datasets more efficiently than `with_items`.
4. **Deprecation**: `with_items` is considered deprecated in favor of `loop`, and it is recommended to use `loop` for all new playbooks to ensure compatibility with future versions of Ansible.

---

### Task 6: Register, Debug, and Combine Everything
Build a real-world playbook `server-report.yml` that combines variables, facts, conditionals, and register:

```yaml
---
- name: Server Health Report
  hosts: all

  tasks:
    - name: Check disk space
      command: df -h /
      register: disk_result

    - name: Check memory
      command: free -m
      register: memory_result

    - name: Check running services
      shell: systemctl list-units --type=service --state=running | head -20
      register: services_result

    - name: Generate report
      debug:
        msg:
          - "========== {{ inventory_hostname }} =========="
          - "OS: {{ ansible_distribution }} {{ ansible_distribution_version }}"
          - "IP: {{ ansible_default_ipv4.address }}"
          - "RAM: {{ ansible_memtotal_mb }}MB"
          - "Disk: {{ disk_result.stdout_lines[1] }}"
          - "Running services (first 20): {{ services_result.stdout_lines | length }}"

    - name: Flag if disk is critically low
      debug:
        msg: "ALERT: Check disk space on {{ inventory_hostname }}"
      when: "'9[0-9]%' in disk_result.stdout or '100%' in disk_result.stdout"

    - name: Save report to file
      copy:
        content: |
          Server: {{ inventory_hostname }}
          OS: {{ ansible_distribution }} {{ ansible_distribution_version }}
          IP: {{ ansible_default_ipv4.address }}
          RAM: {{ ansible_memtotal_mb }}MB
          Disk: {{ disk_result.stdout }}
          Checked at: {{ ansible_date_time.iso8601 }}
        dest: "/tmp/server-report-{{ inventory_hostname }}.txt"
      become: true
```

Run it and verify the report file is created on each server.

![task6](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/341107d39b000534918e3e23105555ebd2edb809/2026/day-70/images/task%206.JPG)

![task6.1](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/341107d39b000534918e3e23105555ebd2edb809/2026/day-70/images/task%206.1.JPG)

**Verify:** SSH into a server and read `/tmp/server-report-*.txt`. Does it contain accurate information?
-   yes
---

- **App Server**

![task6.2](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/341107d39b000534918e3e23105555ebd2edb809/2026/day-70/images/task%206.2.JPG)

- **DB Server**

![task6.3](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/341107d39b000534918e3e23105555ebd2edb809/2026/day-70/images/task%206.3.JPG)

- **Web Server**

![task6.4](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/341107d39b000534918e3e23105555ebd2edb809/2026/day-70/images/task%206.4.JPG)

---

-  `group_vars/` and `host_vars/` directory structure

![task7](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/2d339eab4aff881945a5d2d7208432c4bfffb063/2026/day-70/images/2.JPG)

---



