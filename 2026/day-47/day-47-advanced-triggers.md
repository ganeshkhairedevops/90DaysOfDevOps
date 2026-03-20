# Day 47 – Advanced Triggers: PR Events, Cron Schedules & Event-Driven Pipelines
📌 Overview
In Day 47, I explored advanced GitHub Actions triggers beyond basic push and pull_request. This includes PR lifecycle events, cron schedules, smart triggers, workflow chaining, and external event-based pipelines.

## Challenge Tasks

### Task 1: Pull Request Event Types

I created `.github/workflows/pr-lifecycle.yml` to trigger on specific pull_request events: opened, synchronize, reopened, and closed. The workflow prints the event type, PR title, author, source and target branches. It also has a conditional step that runs only when the PR is merged.
```yml
name: PR Lifecycle Events

on:
  pull_request:
    types: [opened, synchronize, reopened, closed]

jobs:
  pr-info:
    runs-on: ubuntu-latest

    steps:
      - name: Print PR Event Info
        run: |
          echo "Event Type: ${{ github.event.action }}"
          echo "PR Title: ${{ github.event.pull_request.title }}"
          echo "PR Author: ${{ github.event.pull_request.user.login }}"
          echo "Source Branch: ${{ github.head_ref }}"
          echo "Target Branch: ${{ github.base_ref }}"

      - name: Run only if PR is merged
        if: github.event.pull_request.merged == true
        run: echo "PR was merged successfully"
```
I tested it by creating a PR, pushing updates, and merging it. The workflow fired correctly for each event type.

![task1]()

![taks1.1]()

### Task 2: PR Validation Workflow
I created `.github/workflows/pr-checks.yml` to validate PRs against specific criteria. It has three jobs: `file-size-check`, `branch-name-check`, and `pr-body-check`. The first two jobs fail if the PR doesn't meet the requirements, while the last one warns if the PR description is empty.
```yml
name: PR Checks

on:
  pull_request:
    branches:
      - main

jobs:
  file-size-check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Check file size
        run: |
          for file in $(git diff --name-only origin/main); do
            size=$(stat -c%s "$file")
            if [ "$size" -gt 1048576 ]; then
              echo "File $file is larger than 1MB"
              exit 1
            fi
          done

  branch-name-check:
    runs-on: ubuntu-latest
    steps:
      - name: Validate branch name
        run: |
          echo "Branch: ${{ github.head_ref }}"
          if [[ ! "${{ github.head_ref }}" =~ ^(feature|fix|docs)/ ]]; then
            echo "Invalid branch name!"
            exit 1
          fi

  pr-body-check:
    runs-on: ubuntu-latest
    steps:
      - name: Check PR description
        run: |
          if [ -z "${{ github.event.pull_request.body }}" ]; then
            echo "Warning: PR description is empty"
          fi
```
I tested it by creating a PR with a badly named branch. The checks behaved as expected.

![task2]()

### Task 3: Scheduled Workflows (Cron Deep Dive)
I created `.github/workflows/scheduled-tasks.yml` with two cron schedules: every Monday at 2:30 AM UTC and every 6 hours. The workflow prints which schedule triggered it and performs a health check by curling a URL.
```yml
name: Scheduled Tasks

on:
  schedule:
    - cron: '30 2 * * 1'
    - cron: '0 */6 * * *'
  workflow_dispatch:

jobs:
  cron-job:
    runs-on: ubuntu-latest

    steps:
      - name: Print Schedule
        run: |
          echo "Triggered by cron: ${{ github.event.schedule }}"

      - name: Health Check
        run: |
          STATUS=$(curl -o /dev/null -s -w "%{http_code}" https://www.google.com/)
          echo "Status Code: $STATUS"
```
I also noted the cron expressions for specific schedules and why GitHub may delay or skip scheduled workflows on inactive repos.

![task3]()

**Notes:**

- The cron expression for: every weekday at 9 AM IST
```
0 3 * * 1-5
```
- The cron expression for: first day of every month at midnight
```
0 0 1 * *
```
- Why GitHub says scheduled workflows may be delayed or skipped on inactive repos?

GitHub may delay or skip scheduled workflows on inactive repositories to conserve resources. If a repository hasn't had any activity (like commits, PRs, or issues) for a certain period, GitHub considers it inactive and may not run scheduled workflows as frequently or at all until there is new activity.


### Task 4: Path & Branch Filters
I created `.github/workflows/smart-triggers.yml` to demonstrate path and branch filters. It triggers on pushes that change files in `src/` or `app/`, and ignores changes to `.md` files or anything in `docs/`. It also only triggers on `main` and `release/*` branches.
```yml
name: Smart Trigger

on:
  push:
    branches:
      - main
      - release/*
    paths:
      - 'src/**'
      - 'app/**'

jobs:
  run-on-code-change:
    runs-on: ubuntu-latest
    steps:
      - name: Print message
        run: |
            echo "Workflow triggered because src/ or app/ changed!"
            echo "Code files changed"

```
![task4]()

I tested it by pushing changes to a `.md` file and confirming that the workflow skipped, while changes to code files triggered it.
```yml
name: Ignore Docs Changes

on:
  push:
    branches:
      - main
      - release/*
    paths-ignore:
      - '*.md'
      - 'docs/**'

jobs:
  skip-docs:
    runs-on: ubuntu-latest
    steps:
      - run: echo "Docs-only change skipped"
```
**Write in your notes: When would you use paths vs paths-ignore?**
- Use `paths` when you want to **only trigger** the workflow for specific files or directories. This is a whitelist approach.
- Use `paths-ignore` when you want to trigger the workflow for all changes **except** certain files or directories. This is a blacklist approach.


### Task 5: `workflow_run` — Chain Workflows Together
I created two workflows: `tests.yml` that runs tests on every push, and `deploy-after-tests.yml` that triggers only after `tests.yml` completes successfully.
```yml
name: Run Tests

on:
  push:

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Repository
        uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: 18
      - run: echo "Running tests..."
```

```yml
name: Deploy After Tests

on:
  workflow_run:
    workflows: ["Run Tests"]
    types: [completed]

jobs:
  deploy:
    runs-on: ubuntu-latest
    if: github.event.workflow_run.conclusion == 'success'

    steps:
      - run: echo "Deploying application..."

  fail-handler:
    runs-on: ubuntu-latest
    if: github.event.workflow_run.conclusion != 'success'

    steps:
      - run: echo "Tests failed. Deployment skipped."
```

I tested it by pushing a commit. The test workflow ran first, and upon completion, the deploy workflow triggered. If the tests succeeded, it proceeded with deployment; if they failed, it printed a warning and skipped deployment.

![task5]()

### Task 6: `repository_dispatch` — External Event Triggers

I created `.github/workflows/external-trigger.yml` that listens for `repository_dispatch` events with the type `deploy-request`. It prints the client payload environment variable when triggered.

```yml
name: External Trigger

on:
  repository_dispatch:
    types: [deploy-request]

jobs:
  external:
    runs-on: ubuntu-latest

    steps:
      - name: Print Payload
        run: |
            echo "Environment: ${{ github.event.client_payload.environment }}"
```
I triggered it using the `gh` CLI:
```bash
gh api repos/ganeshkhairedevops/github-actions-practice/dispatches \
  -f event_type=deploy-request \
  -f client_payload='{"environment":"production"}'
```
but not work, GitHub CLI is treating this as a string, not a JSON object

Use --raw-field

```bash
gh api repos/ganeshkhairedevops/github-actions-practice/dispatches \
  --method POST \
  -f event_type=deploy-request \
  -f client_payload[environment]=production
```
![task6]()

I verified that the workflow ran and printed the environment variable correctly.

or can use JSON
```bash
gh api repos/ganeshkhairedevops/github-actions-practice/dispatches \
  --method POST \
  --input - <<EOF
{
  "event_type": "deploy-request",
  "client_payload": {
    "environment": "production"
  }
}
EOF
```
![task6.1]()

**Write in your notes: When would an external system (like a Slack bot or monitoring tool) trigger a pipeline?**
An external system might trigger a pipeline in scenarios such as:
- A Slack bot could trigger a deployment pipeline when a user sends a specific command, allowing for manual deployments without needing to push code.
- A monitoring tool could trigger a rollback pipeline if it detects a critical issue in production, enabling automated recovery actions.
---
**Explanation of `workflow_run` vs `workflow_call` in your own words**
- `workflow_run` is used to trigger a workflow based on the completion of another workflow. It allows you to chain workflows together, where one workflow runs after another finishes, and you can conditionally check the outcome of the previous workflow.
- `workflow_call` is used to create reusable workflows that can be called from other workflows. It allows you to define a workflow that can be invoked with specific inputs and secrets, and it can return outputs to the calling workflow. This promotes modularity and reuse of common workflow logic across different workflows.

