# Day 26 – GitHub CLI (gh)

---

# 🚀 Task 1: Install & Authenticate

## Installation

Ubuntu:
```bash
sudo apt install gh
```
Mac:
```bash
brew install gh
```

Windows:
```bash
winget install GitHub.cli
```
---

## Authenticate
```bash
gh auth login
```
Follow prompts:
- GitHub.com
- HTTPS
- Login via browser

---

## Verify Login
```bash
gh auth status
```
---

## What authentication methods does gh support?

- Browser-based OAuth login
- Personal Access Token (PAT)
- SSH authentication

---

# 📦 Task 2: Working with Repositories

## Create a repo
```bash
gh repo create devops-gh-test --public --source=. --remote=origin --push
```
Or simple:
```bash
gh repo create devops-gh-test --public --add-readme
```
---
## List all repos
```bash
gh repo list
```

## Clone using gh

for example:

 gh repo clone ganeshkhairedevops/devops-gh-test
```bash
gh repo clone owner/repo
```
---

## View repo details

gh repo view owner/repo

---
## Open repo in browser

gh repo view --web

---

## Delete repo
for example:

gh repo delete devops-gh-test --confirm
```bash
gh repo delete owner/repo --confirm
```
⚠ Be careful — this permanently deletes the repo.

---

# 🐞 Task 3: Issues

## Create issue
Go to git repo
```bash
gh issue create \
--title "Test Issue from CLI" \
--body "Created using GitHub CLI for Day 26 practice" \
--label "bug"
```
---

## List open issues
```bash
gh issue list
```
---

## View specific issue
```bash
gh issue view 1
```
---

## Close issue
```bash
gh issue close 1
```
---

## How could gh issue be used in automation?

- Auto-create issues when CI fails
- Generate tickets from monitoring alerts
- Script issue reporting in pipelines

---

# 🔀 Task 4: Pull Requests

## Create branch & push
```bash
git switch -c feature-cli-test
git commit -am "add cli test"
git push -u origin feature-cli-test
```
---

## Create PR from terminal
```bash
gh pr create --fill
```
---

## List PRs
```bash
gh pr list
```
---

## View PR details
```bash
gh pr view 1
```
---

## Merge PR
```bash
gh pr merge 1 --merge
```
---

## What merge methods does gh pr merge support?

- --merge (default merge commit)
- --squash
- --rebase

---

## How to review someone else's PR?
```bash
gh pr checkout <number>
Review code
gh pr review --approve
gh pr review --comment
gh pr review --request-changes
```
---

# ⚙ Task 5: GitHub Actions

## List workflow runs
```bash
gh run list
```
---

## View specific run
```bash
gh run view <run-id>
```
---

## How could gh run & gh workflow help in CI/CD?

- Monitor pipeline status from terminal
- Automatically cancel failed runs
- Trigger workflows via automation scripts
- Extract workflow results in JSON for reporting

---

# 🛠 Task 6: Useful gh Tricks

## gh api
Make raw API calls

Example:
gh api repos/:owner/:repo

---

## gh gist
```bash
Create gist
```
gh gist create file.txt

---

## gh release
Create release

gh release create v1.0.0

---

## gh alias
Create shortcuts

gh alias set prc "pr create --fill"

---

## gh search repos
Search GitHub

gh search repos "terraform aws"

---

# 🎯 Why gh is Important for DevOps

- Automate PR creation
- Script repository management
- Integrate with CI/CD pipelines
- Avoid browser context switching
- Work faster in terminal-only servers