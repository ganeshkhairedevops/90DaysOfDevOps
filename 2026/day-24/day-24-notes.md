# Day 24 – Advanced Git: Merge, Rebase, Stash & Cherry Pick

## 🔀 Merge

### What is a fast-forward merge?
A fast-forward merge happens when the main branch has not moved ahead.
Git simply moves the branch pointer forward without creating a new merge commit.

### When does Git create a merge commit?
When both branches have new commits.
Git creates a merge commit to combine the histories.

### What is a merge conflict?
A merge conflict occurs when two branches modify the same line of a file.
Git cannot automatically resolve it and requires manual intervention.


---

## 🔄 Rebase

### What does rebase do?
Rebase replays your commits on top of another base branch.
It rewrites commit history and creates a linear timeline.

### How is history different from merge?
Merge preserves branch history and creates a merge commit.
Rebase creates a cleaner, linear history without merge commits.

### Why should you not rebase shared commits?
Because rebase changes commit hashes and rewrites history,
which can break collaboration and cause confusion.

### When to use rebase vs merge?
Rebase → Clean up local commits before pushing.
Merge → When integrating shared or public branches.


---

## 🧹 Squash Merge

### What does squash merging do?
It combines multiple commits into a single commit before merging.

### When to use squash merge?
When small or messy commits should appear as one clean feature commit.

### Trade-off of squashing?
You lose detailed commit history from that branch.


---

## 👜 Git Stash

### Difference between git stash pop and git stash apply?
git stash pop → Applies and removes the stash.

git stash apply → Applies but keeps the stash in the list.

### When to use stash?
When you need to temporarily save unfinished work
and switch context quickly without committing.


---

## 🍒 Cherry Pick

### What does cherry-pick do?
It applies a specific commit from another branch onto the current branch.

### When to use cherry-pick?
For hotfixes or selective changes that need to be applied
without merging the entire branch.

### What can go wrong?
Conflicts, duplicate commits, and confusing history if overused.
