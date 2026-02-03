# Day 10 – File Permissions & File Operations Challenge

Today I practiced creating files, reading them, and understanding
Linux file permissions. This is critical for working with scripts,
configs, and shared environments.

---

## Task 1: Create Files

```bash
touch devops.txt
echo "This is DevOps notes file" > notes.txt
vim script.sh
```

Content inside script.sh:
```bash
echo "Hello DevOps"
```

Verify:
```bash
ls -l
```

---

## Task 2: Read Files

```bash
cat notes.txt
vim -R script.sh
head -n 5 /etc/passwd or cat /etc/passwd | head -n 5
tail -n 5 /etc/passwd r cat /etc/passwd | tail -n 5
```
---
![task 1 and 2](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/9bca09082900857d34a727cb56964642ff291045/2026/day-10/images/task1%2C2.jpg)
---

## Task 3: Understand Permissions

```bash
ls -l devops.txt notes.txt script.sh
```
---
![task 3](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/9bca09082900857d34a727cb56964642ff291045/2026/day-10/images/task%203.jpg)
---

## Task 4: Modify Permissions

```bash
chmod +x script.sh
./script.sh
chmod 400 devops.txt
chmod 640 notes.txt
mkdir project
chmod 755 project
ls -l
```
---
![task 4](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/9bca09082900857d34a727cb56964642ff291045/2026/day-10/images/task%204.jpg)

---

## Task 5: Test Permissions

```bash
echo "test" >> devops.txt
chmod -x script.sh
./script.sh
```

---

## What I Learned

- Permissions control access
- Execute permission is required
- chmod is critical in DevOps
---