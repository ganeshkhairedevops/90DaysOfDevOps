# Day 09 – Linux User & Group Management Challenge

Today I practiced Linux user and group management by creating users,
assigning groups, and setting shared directory permissions.

---

## Users & Groups Created

### Users
- tokyo
- berlin
- professor
- nairobi

### Groups
- developers
- admins
- project-team

---

## Task 1: Create Users
```bash
sudo useradd -m tokyo
sudo passwd tokyo

sudo useradd -m berlin
sudo passwd berlin

sudo useradd -m professor
sudo passwd professor

Verification:
cat /etc/passwd | grep -E "tokyo|berlin|professor"
ls -l /home
```
---
Screenshot

---

## Task 2: Create Groups
```bash
sudo groupadd developers
sudo groupadd admins

Verification:
cat /etc/group | grep -E "developers|admins"
```
---

## Task 3: Assign Users to Groups
```bash
sudo usermod -aG developers tokyo
sudo usermod -aG developers,admins berlin
sudo usermod -aG admins professor
```

Verification:
```bash
groups tokyo
groups berlin
groups professor
```
or 
```bash
cat /etc/group
```
---


## Task 4: Shared Directory
```bash
sudo mkdir /opt/dev-project
sudo chgrp developers /opt/dev-project
sudo chmod 775 /opt/dev-project
```
```bash
Test:
sudo -u tokyo touch /opt/dev-project/tokyo-file.txt
sudo -u berlin touch /opt/dev-project/berlin-file.txt
```
---

## Task 5: Team Workspace
```bash
sudo useradd -m nairobi
sudo passwd nairobi

sudo groupadd project-team
sudo usermod -aG project-team nairobi
sudo usermod -aG project-team tokyo

sudo mkdir /opt/team-workspace
sudo chgrp project-team /opt/team-workspace
sudo chmod 775 /opt/team-workspace
```
Test:
```bash
sudo -u nairobi touch /opt/team-workspace/nairobi-file.txt
```
---

## What I Learned
- Users and groups manage access
- Group permissions enable collaboration
- sudo -u helps test access safely
