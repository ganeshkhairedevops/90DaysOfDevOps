# Day 28 – Revision & Self Assessment

Today was a full revision day covering everything from Day 1 to Day 27.
The goal was not learning something new, but strengthening foundations.

---

# ✅ Task 1 – Self Assessment Checklist

## 🐧 Linux

✔ Navigate file system confidently  
✔ Manage processes (ps, top, kill, bg, fg)  
✔ Work with systemd (start, stop, enable, status)  
✔ Edit files using vim/nano  
✔ Troubleshoot CPU, memory, disk issues  
✔ Explain Linux file system hierarchy  
✔ Manage users and groups  
✔ Set file permissions (numeric & symbolic)  
✔ Change ownership (chown, chgrp)  
✔ Create and manage LVM  
✔ Perform network checks (ping, curl, ss, netstat)  
✔ Explain DNS, IP addressing, subnets, ports  

---

## 🐚 Shell Scripting

✔ Write scripts with variables and arguments  
✔ Use if/elif/else and case  
✔ Write loops (for, while, until)  
✔ Use functions with arguments  
✔ Use grep, awk, sed for text processing  
✔ Schedule scripts using crontab  

Need to revisit:
- Advanced error handling (trap, pipefail combinations)

---

## 🔀 Git & GitHub

✔ Initialize repo, stage, commit  
✔ Branching and switching  
✔ Push & pull from GitHub  
✔ Clone vs Fork difference  
✔ Merge & Fast-forward merge  
✔ Rebase and when to use it  
✔ Stash usage  
✔ Cherry-pick  
✔ Reset vs Revert  
✔ Branching strategies (GitFlow, GitHub Flow, Trunk)  
✔ GitHub CLI usage  

---

# 🔁 Task 2 – Topics Revisited

### 1️⃣ LVM
Re-practiced creating:
- Physical volume (pvcreate)
- Volume group (vgcreate)
- Logical volume (lvcreate)
- Formatting and mounting

Re-learned that LVM allows flexible resizing without repartitioning.

---

### 2️⃣ set -euo pipefail
Re-tested how:
- set -e stops script on error
- set -u fails on undefined variables
- set -o pipefail detects pipeline failures

Important for production scripts.

---

### 3️⃣ Git Rebase vs Merge
Re-practiced rebasing a feature branch.
Confirmed:
- Rebase creates linear history
- Merge preserves branch history

---

# ⚡ Task 3 – Quick Fire Answers

### What does chmod 755 script.sh do?
Gives owner full permissions (rwx) and group/others read & execute (r-x).

---

### Difference between process and service?
Process = running instance of a program.  
Service = long-running background process managed by systemd.

---

### How to find which process uses port 8080?
ss -tulpn | grep 8080

---

### What does set -euo pipefail do?
Stops script on error, fails on undefined variables, and detects pipe failures.

---

### Difference between git reset --hard and git revert?
reset --hard rewrites history and deletes changes.  
revert creates a new commit that undoes changes safely.

---

### Best branching strategy for 5 developers shipping weekly?
GitHub Flow — simple feature branches + PRs.

---

### What does git stash do?
Temporarily saves uncommitted changes so you can switch branches.

---

### How to run script daily at 3 AM?
0 3 * * * /path/script.sh

---

### Difference between git fetch and git pull?
fetch downloads changes.  
pull downloads and merges automatically.

---

### What is LVM?
Logical Volume Manager allows flexible disk management and resizing.

---

# 🧠 Task 5 – Teach It Back

## Explaining Git Branching to a Non-Developer

Git branching is like creating a copy of a document to make changes safely.
Instead of editing the main version, you work on a separate copy (branch).
Once you're done and everything works, you merge it back.
This prevents breaking the original project while experimenting.

---

# 📌 Final Check

✔ All days pushed (1–27)  
✔ git-commands.md updated  
✔ Shell cheat sheet complete  
✔ GitHub profile clean  
✔ Repositories organized  

Day 28 complete.
Foundations are stronger.