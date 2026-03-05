# Day 41 – GitHub Actions Triggers & Matrix Builds

Today I learned different ways to trigger GitHub Actions workflows and how to run jobs across multiple environments using matrix builds.

---
# Task 1: Pull Request Trigger

Workflow file: `.github/workflows/pr-check.yml`
```yaml
name: PR Check

on:
  pull_request:
    branches: [ main ]

jobs:
  pr-check:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Print PR branch
        run: 'echo "PR check running for branch: ${{ github.head_ref }}"'
```

This workflow runs whenever a pull request is opened or updated against the main branch.

It prints the branch name of the PR using:
```
${{ github.head_ref }}
```
This helps validate code before merging.

![task1](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/17906ff70e625f31d6ad910c68d93eee019b9131/2026/day-41/images/task%201.jpg)

---

# Task 2: Scheduled Trigger

Cron trigger example:
```
0 0 * * *
```
This runs the workflow every day at midnight UTC.

Cron expression for **every Monday at 9 AM**:
```
0 9 * * 1
```
This runs the workflow every Monday at 9 AM UTC.
---
# Task 3: Manual Trigger

Workflow file: `.github/workflows/manual.yml`

```yaml

name: Manual Trigger
on:
  workflow_dispatch:
    inputs:
      environment:
        description: 'Environment to deploy to'
        required: true
        default: 'staging'
jobs:
    print-input:
        runs-on: ubuntu-latest
        steps:
          - name: Print environment input
            run: 'echo "Deploying to environment: ${{ github.event.inputs.environment }}"'
```
This workflow can be triggered manually from the Actions tab.

Go to

GitHub → Actions → Manual Workflow → Run Workflow

It asks for an environment input and prints it when run.

![task3](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/17906ff70e625f31d6ad910c68d93eee019b9131/2026/day-41/images/task%203.jpg)
![task3.1](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/17906ff70e625f31d6ad910c68d93eee019b9131/2026/day-41/images/task3.1.jpg)
![task3.2](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/17906ff70e625f31d6ad910c68d93eee019b9131/2026/day-41/images/task3.2.jpg)

---
# Task 4: Matrix Builds
Workflow file: `.github/workflows/matrix.yml`
```yaml
name: Matrix Build

on:
  push:

jobs:
  build:
    runs-on: ${{ matrix.os }}

    strategy:
      matrix:
        os: [ubuntu-latest, windows-latest]
        python-version: [3.10, 3.11, 3.12]

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Python
        uses: actions/setup-python@v4
        with:
          python-version: ${{ matrix.python-version }}

      - name: Print Python Version
        run: python --version
```

- Windows 3.12
The excluded combination is Windows 3.10.

![task4](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/17906ff70e625f31d6ad910c68d93eee019b9131/2026/day-41/images/task%204.jpg)

---
# Task 5: Exclude & Fail-Fast
To exclude a specific combination in the matrix:
```yaml
name: Matrix Build

on:
  push:

jobs:
  build:
    name: Python ${{ matrix.python-version }} on ${{ matrix.os }}
    runs-on: ${{ matrix.os }}

    strategy:
      fail-fast: false
      matrix:
        os: [ubuntu-latest, windows-latest]
        python-version: ["3.10", "3.11", "3.12"]

        exclude:
          - os: windows-latest
            python-version: "3.10"

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Setup Python
        uses: actions/setup-python@v5
        with:
          python-version: ${{ matrix.python-version }}

      - name: Print Python version
        run: python --version

      - name: Print OS
        run: echo "Running on $RUNNER_OS"

      - name: Simulate failure for testing
        if: matrix.python-version == '3.11' && matrix.os == 'ubuntu-latest'
        run: exit 1
```
With `fail-fast: false`, if one job fails, the others will continue running. If it were `true`, all other jobs would be canceled immediately when one fails.

In the job that runs Python 3.11 on Ubuntu. The `if` condition checks if the current matrix combination is Python 3.11 and Ubuntu, and if so, it executes `exit 1`, which causes that specific job to fail.

![task5](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/17906ff70e625f31d6ad910c68d93eee019b9131/2026/day-41/images/task%205.jpg)

---

