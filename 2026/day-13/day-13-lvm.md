# Day 13 – Linux Volume Management (LVM)

Today I learned and practiced Linux Logical Volume Management (LVM).
LVM allows flexible disk management like creating, extending,
and resizing storage without downtime.

---

## Pre-requisites

```bash
sudo -i
```

---

## Task 1: Check Current Storage

```bash
lsblk
pvs
vgs
lvs
df -h
```
![task 1](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/f5b50096a160479c3b9dd950a5fe70d5ef7aaab5/2026/day-13/images/task%201.jpg)
---

## Task 2: Create Physical Volume

```bash
pvcreate /dev/xvdf
pvs
```
![task 2](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/f5b50096a160479c3b9dd950a5fe70d5ef7aaab5/2026/day-13/images/task%202.jpg)
---

## Task 3: Create Volume Group

```bash
vgcreate devops-vg /dev/xvdf
vgs
```
![task 3](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/f5b50096a160479c3b9dd950a5fe70d5ef7aaab5/2026/day-13/images/task%203.jpg)
---

## Task 4: Create Logical Volume

```bash
lvcreate -L 500M -n app-data devops-vg
lvs
```
![task 4](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/f5b50096a160479c3b9dd950a5fe70d5ef7aaab5/2026/day-13/images/task%204.jpg)
---

## Task 5: Format and Mount

```bash
mkfs.ext4 /dev/devops-vg/app-data
mkdir -p /mnt/app-data
mount /dev/devops-vg/app-data /mnt/app-data
df -h /mnt/app-data
```
![task 5](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/f5b50096a160479c3b9dd950a5fe70d5ef7aaab5/2026/day-13/images/task%205.jpg)
---

## Task 6: Extend Logical Volume

```bash
lvextend -L +200M /dev/devops-vg/app-data
resize2fs /dev/devops-vg/app-data
df -h /mnt/app-data
```
![task 6](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/f5b50096a160479c3b9dd950a5fe70d5ef7aaab5/2026/day-13/images/task%206.jpg)
---
## Other Screenshots :
Instead of creating the EC2 instance manually, I provisioned
the cloud server using Terraform.

![terraform apply](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/d5fb5b6c90735f16b02d68c35d08053d847b0e39/2026/day-13/images/tfa.png)
![terraform destroy](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/d5fb5b6c90735f16b02d68c35d08053d847b0e39/2026/day-13/images/tfd.jpg)

## Commands Used
- dd
- losetup
- lsblk
- pvcreate
- vgcreate
- lvcreate
- lvextend
- resize2fs
- mount
- df

---

## What I Learned
- LVM enables flexible storage management
- Logical volumes can be extended online
- Loop devices are useful for practice
