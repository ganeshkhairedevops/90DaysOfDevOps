# Day 22 Notes – Git Fundamentals

## TASK 1 – Install & Configure Git
### 1️⃣ Verify Git installation
```bash
git --version
```
If installed, you’ll see something like:
```bash
git version 2.xx.x
```
### 2️⃣ Set your Git identity
```bash
git config --global user.name "ganeshkhairedevops"
git config --global user.email "ganeshkhaire14@gmail.com"
```
### 3️⃣ Verify configuration
```bash
git config --list
```
or:
```bash
git config user.name
git config user.email
```
## ✅ TASK 2 – Create Your Git Project
### 1️⃣ Create project folder
```bash
mkdir devops-git-practice
cd devops-git-practice
```
### 2️⃣ Initialize Git
```bash
git init
```
Output:

Initialized empty Git repository in ...

### 3️⃣ Check status
```bash
git status
```
You’ll see:
```bash
On branch master

No commits yet
```
### 4️⃣ Explore the hidden .git folder
```bash
ls -a
cd .git
ls
```
Important folders inside .git/:

objects/ → stores commits & files

refs/ → stores branches

HEAD → points to current branch

config → repository configuration

⚠️ If you delete .git, your project becomes a normal folder. History is permanently gone.

## ✅ TASK 3 – Create git-commands.md
Create file:
```bash
touch git-commands.md
```
copy git-commands.md file 
## TASK 4 – Stage & Commit
### 1️⃣ Stage file
```bash
git add git-commands.md
```
### 2️⃣ Check staged
```bash
git status
```
### 3️⃣ Commit
```bash
git commit -m "Add initial Git commands reference"
```
### 4️⃣ View history
```bash
git log
```
## TASK 5 – Build Commit History

1. Edit git-commands.md
2. Add new commands
3. Then:
```bash
git add git-commands.md
git commit -m "Add git diff command"
```
Final check:

```bash
git log --oneline
```
## TASK 6 – Understand the Git Workflow
## 1. Difference between git add and git commit

git add moves changes from the working directory to the staging area.
git commit saves the staged changes into the repository history.

---

## 2. What does the staging area do?

The staging area allows us to control what changes go into a commit.
It prevents accidental commits and allows logical grouping of changes.

---

## 3. What does git log show?

git log shows:
- Commit ID (SHA)
- Author
- Date
- Commit message

---

## 4. What is the .git folder?

The .git folder stores:
- All commits
- Branch information
- Configuration
- Objects database

If deleted, the repository history is permanently lost.

---

## 5. Working Directory vs Staging vs Repository

Working Directory → Where files are edited  
Staging Area → Where changes are prepared  
Repository → Where commits are permanently stored
