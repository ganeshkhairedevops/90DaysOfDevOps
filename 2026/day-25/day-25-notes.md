# Day 25 – Git Reset vs Revert & Branching Strategies

---

# 🔁 Task 1: Git Reset

## Difference Between --soft, --mixed, and --hard

### git reset --soft <commit>
Moves HEAD to previous commit  
Keeps changes staged (in staging area)

### git reset --mixed <commit> (default)
Moves HEAD  
Keeps changes in working directory (unstaged)

### git reset --hard <commit>
Moves HEAD  
Deletes changes completely from working directory

---

## Which one is destructive?

git reset --hard

Because it permanently deletes uncommitted changes.

---

## When to use each?

--soft → When you want to modify the last commit  
--mixed → When you want to unstage changes  
--hard → When you want to completely discard changes  

---

## Should you use reset on pushed commits?

No.

Because reset rewrites history and can break shared branches.

---

# 🔄 Task 2: Git Revert

When reverting commit Y:

- Git creates a NEW commit
- That new commit undoes changes from Y
- Original commit Y remains in history

---

## Is commit Y still in history?

Yes. Revert does NOT remove it.
It adds a reverse commit.

---

## Reset vs Revert

Reset:
- Moves branch pointer
- Can delete history
- Unsafe for shared branches

Revert:
- Creates new undo commit
- Keeps history intact
- Safe for shared branches

---

## When to use revert vs reset?

Use reset → For local cleanup before pushing  
Use revert → For undoing changes in shared branches  

---

# 📊 Task 3: Reset vs Revert Comparison

| Feature | git reset | git revert |
|----------|------------|------------|
| What it does | Moves branch pointer | Creates new undo commit |
| Removes commit from history? | Yes | No |
| Safe for pushed branches? | No | Yes |
| When to use | Local cleanup | Production fixes |

---

# 🌿 Task 4: Branching Strategies

---

## 1️⃣ GitFlow

### How it works:
- main (production)
- develop (integration)
- feature branches
- release branches
- hotfix branches

### Flow:
feature → develop → release → main  
hotfix → main → develop

### Used for:
Large teams with scheduled releases

### Pros:
- Structured
- Clear release control

### Cons:
- Complex
- Slower delivery

---

## 2️⃣ GitHub Flow

### How it works:
- Single main branch
- Feature branches
- Pull request → merge to main

### Flow:
feature → pull request → main

### Used for:
Web apps, continuous deployment

### Pros:
- Simple
- Fast

### Cons:
- Requires strong CI/CD

---

## 3️⃣ Trunk-Based Development

### How it works:
- Everyone commits to main
- Short-lived branches
- Frequent integration

### Flow:
short feature branch → main quickly

### Used for:
High-velocity teams (Google-style)

### Pros:
- Fast integration
- Less merge pain

### Cons:
- Requires mature testing

---

# 🎯 Strategy Decisions

### Startup shipping fast?
GitHub Flow or Trunk-Based Development

### Large enterprise with scheduled releases?
GitFlow

### Example Open Source Project:
Kubernetes uses a structured release branching model.
Many modern projects use GitHub Flow.

---

