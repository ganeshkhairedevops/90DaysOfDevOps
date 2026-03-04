# Day 40 – My First GitHub Actions Workflow

Today I created my first CI pipeline using GitHub Actions.

---
# Challenge Tasks
## Task 1: Set Up
1. Create a new **public** GitHub repository called `github-actions-practice`
2. Clone it locally
3. Create the folder structure: `.github/workflows/`

## Workflow File

```yaml
# This is a basic GitHub Actions workflow that runs on every push to the repository.
# # Name of the worflow
name: Hello Workflow

# Trigger the workflow on push events
on:
  push:

# Define the jobs to run in the workflow
jobs:
  greet:
    # The type of runner to use for this job
    runs-on: ubuntu-latest

    # The steps to execute in this job
    steps:
        # Checkout the repository to the runner
      - name: Checkout repository
        uses: actions/checkout@v4

        # Run a series of commands to demonstrate the workflow
      - name: Print greeting
        run: echo "Hello from GitHub Actions!"
      - name: Print date and time
        run: date

        # Print the branch name that triggered the workflow
      - name: Print branch name
        run: 'echo "Branch: ${{ github.ref_name }}"'

        # List the files in the repository
      - name: List files
        run: ls -la

        # Print the GitHub runner OS
      - name: Print runner OS
        run: 'echo "Runner OS: $RUNNER_OS"'
      
      #- name: Break the pipeline on purpose
       #  run: exit 1
```

![hello.yml](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/f7b921b04012a7cbb832b44ec11ad4770d0e5fd3/2026/day-40/images/task%201.jpg)

---
## Task 2: Hello Workflow
Create .github/workflows/hello.yml with a workflow and Push it. Go to the Actions tab on GitHub and watch it run.

![action](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/f7b921b04012a7cbb832b44ec11ad4770d0e5fd3/2026/day-40/images/task%202.jpg)

![action1](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/f7b921b04012a7cbb832b44ec11ad4770d0e5fd3/2026/day-40/images/task%202.2.jpg)

---

## Task 3: Workflow Anatomy (In My Words)

**on**:
Defines when the workflow runs. In this case, on every push.

**jobs**:
Defines the set of jobs to run.

**runs-on**:
Specifies the operating system of the runner (Ubuntu).

**steps**:
List of sequential actions in a job.

**uses**:
Calls a pre-built GitHub Action.

**run**:
Executes shell commands.

**name**:
Label for readability in the UI.

---

## Task 4: Add More Steps

I updated `hello.yml` to include steps for printing date/time, branch name, listing files, and printing runner OS.

![task 4](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/f7b921b04012a7cbb832b44ec11ad4770d0e5fd3/2026/day-40/images/task%204.jpg)

---
## Task 5: Break It On Purpose

# What a Failed Pipeline Looks Like

When I added `exit 1`, the workflow failed.

The Actions tab showed:
- Red X
- Failed step highlighted
- Error message: Process completed with exit code 1

This is useful because CI catches errors early before deployment.

![task5](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/f7b921b04012a7cbb832b44ec11ad4770d0e5fd3/2026/day-40/images/task%205.jpg)
---

# What I Observed

- Every push triggers a new workflow run.
- Each step executes sequentially.
- Logs show detailed output for debugging.
- A failing command turns the pipeline red.
- Fixing the issue and pushing again restores green status.

![task5.1](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/f7b921b04012a7cbb832b44ec11ad4770d0e5fd3/2026/day-40/images/task%205.1.jpg)

---


# Key Learning

CI/CD is automation in action.

A pipeline is simply:
Trigger → Runner → Steps → Result

Today I moved from understanding CI/CD concepts to running real pipelines in the cloud.
