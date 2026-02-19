# Day 23 Notes – Git Branching & GitHub

## TASK 1 – Understanding Branches

## 1. What is a branch in Git?

A branch is a reference that points to the latest commit in a line of development and moves forward as new commits are made.
It allows you to work on features or fixes independently without affecting the main code.

---

## 2. Why do we use branches instead of committing everything to main?

Branches allow safe experimentation.  
They prevent breaking production code and enable multiple developers to work in parallel.

---

## 3. What is HEAD in Git?

HEAD is a pointer that tells Git which branch or commit you are currently on.

---

## 4. What happens to your files when you switch branches?

Git changes the files in your working directory to match the selected branch's latest commit.

---
## TASK 2 – Branching Commands (Hands-On)
Inside devops-git-practice
### 1️⃣ List branches
```bash
git branch
```
### 2️⃣ Create branch
```bash
git branch feature-1
```
### 3️⃣ Switch to feature-1
```bash
git checkout feature-1
```
or
```bash
git switch feature-1
```
### 4️⃣ Create a new branch and switch
```bash
git checkout -b feature-2
```
or
```bash
git switch -c feature-2
```
### 5️⃣ Switch between branches
```bash
git checkout master
```
Difference:

git checkout → old, used for many things

git switch → modern, only for branch switching (safer)

### 6️⃣ Make commit on feature-1
Switch:
```bash
git switch feature-1
```
Edit git-commands.md → add branching commands section.
and commit
```bash
git add git-commands.md
git commit -m "Add branching commands"
```
### 7️⃣ Verify commit not on main/master
```bash
git switch master
git log --oneline
```
You should not see the "Add branching commands" commit on master.
### 8️⃣ Delete branch
```bash
git branch -d feature-2
```
---
## TASK 3 – Push to GitHub
### 1️⃣ Create Repo on GitHub

Go to GitHub:

Click New Repository

Name: devops-git-practice

DO NOT add README
### 2️⃣ Connect Local Repo
```bash
git remote add origin https://github.com/<your-username>/devops-git-practice.git
```
Verify:
```bash
git remote -v
```
### 3️⃣ Push branch
```bash
git push -u origin master
```
### 4️⃣ Push feature branch
```bash
git push -u origin feature-1
```
### 5️⃣ Verify on GitHub
Now check GitHub → you should see both branches.
### 6️⃣ Difference between origin and upstream
origin → default name for your remote repository (usually your fork)

upstream → the original repository you forked from
---
### TASK 4 – Pull from GitHub
### 1️⃣ Edit file directly on GitHub
(Add a line in README or git-commands.md)
### 2️⃣ Pull locally:
```bash
git pull origin master
```
### 3️⃣ Difference between git fetch and git pull

git fetch → downloads changes but does NOT merge them

git pull → downloads AND merges changes automatically
---
### TASK 5 – Clone vs Fork
## What is the difference between clone and fork?

Clone → Copies a repository to your local machine

Fork → Creates a copy of a repository under your GitHub account

---

## When would you clone vs fork?

Clone → When you want to use or contribute directly
Fork → When contributing to someone else's repository

---

## After forking, how do you keep your fork in sync with the original repo?


Add upstream remote:

git remote add upstream https://github.com/ganeshkhairedevops/devops-git-practice.git

Fetch from upstream:

git fetch upstream

Merge into main:

git merge upstream/main