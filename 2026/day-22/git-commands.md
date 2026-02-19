# Git Commands Reference

## 🔹 Setup & Config

### git --version
Shows installed Git version.  
Example:
git --version

### git config --global user.name
Sets your global username  
Example:
git config --global user.name "ganeshkhairedevops"

### git config --global user.email
Sets your global email  
Example:
git config --global user.email "ganeshkhaire14@gmail.com"

---

## 🔹 Basic Workflow

### git init
Initializes a new Git repository  
Example:
git init

### git add
Stages files for commit  
Example:
git add git-commands.md

### git commit
Creates a snapshot of staged changes  
Example:
git commit -m "Add initial git commands reference"

---

## 🔹 Viewing Changes

### git status
Shows working directory status  
Example:
git status

### git log
Shows commit history  
Example:
git log

### git log --oneline
Shows compact commit history  
Example:
git log --oneline

### git diff
Shows changes between commits  
Example:
git diff

---
## 🔹 Push Local Repository to GitHub

This guide explains how to push an existing local Git repository to GitHub.
### Step 1: Create a Repository on GitHub
Go to https://github.com

Click New Repository

Enter repository name

Do NOT initialize with README

Click Create Repository

### Step 2: Add Remote Repository
Copy your repository URL from GitHub and run:
```bash
git remote add origin https://github.com/ganeshkhairedevops/devops-git-practice.git
```
Verify remote:
```bash
git remote -v
```
### Step 3: Push to GitHub
If using main branch:
```bash
git branch -M main
git push -u origin main
```
If using master branch:
```bash
git push -u origin master
```
### Authentication (Important)

Personal Access Token (HTTPS)
- Username: Your GitHub username
- Password: Use your Personal Access Token

Create token:

GitHub → Settings → Developer Settings → Personal Access Tokens

copy token and add in url and change your git repo 
```bash
git remote set-url origin https://ghp_Xxxxxxxxxxxxxxxxxxx17298@github.com/ganeshkhairedevops/devops-git-practice.git
```

Push again:
```bash
git push -u origin master
```
---
## 🔹 Branching

### git branch
Lists all branches  
Example:
git branch

### git branch <name>
Creates a new branch  
Example:
git branch feature-1

### git switch <branch>
Switches branches  
Example:
git switch main
git checkout branchname

### git switch -c <name>
Creates and switches to a branch  
Example:
git switch -c feature-2

### git branch -d <branch>
Deletes a branch  
Example:
git branch -d feature-2
