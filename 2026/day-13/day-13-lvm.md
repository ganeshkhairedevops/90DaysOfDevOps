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
![task 1]
---

## Task 2: Create Physical Volume

```bash
pvcreate /dev/xvdf
pvs
```

---

## Task 3: Create Volume Group

```bash
vgcreate devops-vg /dev/xvdf
vgs
```

---

## Task 4: Create Logical Volume

```bash
lvcreate -L 500M -n app-data devops-vg
lvs
```

---

## Task 5: Format and Mount

```bash
mkfs.ext4 /dev/devops-vg/app-data
mkdir -p /mnt/app-data
mount /dev/devops-vg/app-data /mnt/app-data
df -h /mnt/app-data
```

---

## Task 6: Extend Logical Volume

```bash
lvextend -L +200M /dev/devops-vg/app-data
resize2fs /dev/devops-vg/app-data
df -h /mnt/app-data
```

---

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
