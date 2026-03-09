# Day 44 – Secrets, Artifacts & Running Real Tests in CI

Today I learned how to manage secrets securely, store artifacts from CI runs, and execute real tests inside GitHub Actions.

---

# Task 1: GitHub Secrets

First create the secret.

Go to repository settings → Secrets and variables → Actions → New repository secret
```
Name: MY_SECRET_MESSAGE
Value: This is a secret message
```
Workflow file: `.github/workflows/secrets.yml`
```yml
name: Secrets Demo

on:
  push:

jobs:
  check-secret:
    runs-on: ubuntu-latest

    steps:
      - name: Check if secret exists
        run: |
          if [ -n "${{ secrets.MY_SECRET_MESSAGE }}" ]; then
            echo "The secret is set: true"
          else
            echo "The secret is missing"
          fi

      - name: Try printing secret
        run: echo "${{ secrets.MY_SECRET_MESSAGE }}"
```

Secrets allow sensitive data like tokens or passwords to be stored securely.

Example secret used:
MY_SECRET_MESSAGE

GitHub automatically masks secret values in logs.

This prevents sensitive information from being exposed in CI logs.

**what does GitHub show?**

GitHub shows *** in place of the actual secret value in logs.

**Why should you never print secrets in CI logs?**

Printing secrets in CI logs can expose sensitive information to anyone with access to the logs, leading to security breaches.

![task1](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/92be56e1634ae207d3d526ccfe9874adf6678afb/2026/day-44/images/task%201.jpg)

---

# Task 2: Use Secrets as Environment Variables
Add Secrets

DOCKER_USERNAME

your docker username

DOCKER_TOKEN

create token

Workflow file: `.github/workflows/use-secrets-env.yml`
```yml
name: Use Secrets as Environment Variables

on:
  push:

jobs:
  use-secret-env:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout Repository
        uses: actions/checkout@v4

      - name: Use secret as environment variable
        env:
          SECRET_MESSAGE: ${{ secrets.MY_SECRET_MESSAGE }}
        run: |
          echo "Secret is available to the workflow."
          echo "Secret length: ${#SECRET_MESSAGE}"

      - name: Check Docker credentials exist
        env:
          DOCKER_USER: ${{ secrets.DOCKER_USERNAME }}
          DOCKER_TOKEN: ${{ secrets.DOCKER_TOKEN }}
        run: |
          if [ -n "$DOCKER_USER" ] && [ -n "$DOCKER_TOKEN" ]; then
            echo "Docker credentials are configured."
          else
            echo "Docker credentials missing."
            exit 1
          fi
```
Secrets can be passed to workflows as environment variables.

Example:
```
${{ secrets.MY_SECRET_MESSAGE }}
```
This allows pipelines to use credentials without hardcoding them.

![task2](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/92be56e1634ae207d3d526ccfe9874adf6678afb/2026/day-44/images/task%202.jpg)

---

# Task 3: Artifacts
Workflow file: `.github/workflows/artifact-upload.yml`
```yml
name: Upload Artifact

on:
  push:

jobs:
  generate-file:
    runs-on: ubuntu-latest

    steps:
      - name: Create report file
        run: |
          echo "CI Test Report" > report.txt
          echo "Generated at $(date)" >> report.txt

      - name: Upload artifact
        uses: actions/upload-artifact@v4
        with:
          name: test-report
          path: report.txt
```
Artifacts allow files generated during workflows to be stored and downloaded later.

Example uses:

Test reports  
Build outputs  
Logs  

Then downloaded it from the Actions tab.

![task3](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/92be56e1634ae207d3d526ccfe9874adf6678afb/2026/day-44/images/task%203.jpg)

---

# Task 4: Download Artifacts Between Jobs
Workflow file: `.github/workflows/artifact-download.yml`
```yml
name: Artifact Download 

on:
  push:

jobs:
  create-artifact:
    runs-on: ubuntu-latest

    steps:
      - name: Create file
        run: echo "Hello from CI" > message.txt

      - name: Upload artifact
        uses: actions/upload-artifact@v4
        with:
          name: message-file
          path: message.txt

  read-artifact:
    runs-on: ubuntu-latest
    needs: create-artifact

    steps:
      - name: Download artifact
        uses: actions/download-artifact@v4
        with:
          name: message-file

      - name: Print artifact contents
        run: cat message.txt
```
Artifacts can be passed between jobs.

Job 1 creates a file.  

![task4](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/1f7a0b82477121996e7a052d56f0998cf72ed1c1/2026/day-44/images/task%204.1.jpg)

Job 2 downloads and uses it.

![task4.1](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/1f7a0b82477121996e7a052d56f0998cf72ed1c1/2026/day-44/images/task%204.2.jpg)

This is useful for multi-stage pipelines.

**When would you use artifacts in a real pipeline?**

Artifacts are useful for sharing build outputs, test results, or any generated files between different stages of a CI/CD pipeline. For example, you might use artifacts to pass compiled code from a build job to a deployment job, or to share test reports between testing and reporting jobs.



---

# Task 5: Run Real Tests in CI
Add one python screept in github-actions-practice repo

Workflow file: `.github/workflows/run-tests.yml`
```yml
name: Run Python Test

on:
  workflow_dispatch: 
  #push:

jobs:
  test-script:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup Python
        uses: actions/setup-python@v5
        with:
          python-version: 3.11

      - name: Run script
        run: python test_script.py
```

I added a Python test script to the repository and executed it in GitHub Actions.

If the script fails, the pipeline fails automatically.
![task5](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/1f7a0b82477121996e7a052d56f0998cf72ed1c1/2026/day-44/images/task%205.1.jpg)

Fixing the script restores the pipeline to a successful state.
![task5.1](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/1f7a0b82477121996e7a052d56f0998cf72ed1c1/2026/day-44/images/task%205.jpg)

---

# Task 6: Caching
Workflow file: `.github/workflows/cache-demo.yml`
```yml
name: Cache Example

on:
  workflow_dispatch:
  #push:

jobs:
  cache-demo:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - name: Setup Python
        uses: actions/setup-python@v5
        with:
          python-version: 3.11

      - name: Cache pip dependencies
        uses: actions/cache@v4
        with:
          path: ~/.cache/pip
          key: ${{ runner.os }}-pip-cache
          restore-keys: |
            ${{ runner.os }}-pip-

      - name: Install dependencies
        run: pip install requests
```
**What Happens**

**First Run**
- Cache **does not exist**
- Dependencies are downloaded from internet
- Cache is **created and stored**
- Logs will show:
```
Cache not found
```
![task6](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/1f7a0b82477121996e7a052d56f0998cf72ed1c1/2026/day-44/images/task%206.jpg)

**Second Run**

- Cache is restored
- Dependencies install much faster
- Logs will show:
```
Cache restored successfully
```
![task6.1](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/1f7a0b82477121996e7a052d56f0998cf72ed1c1/2026/day-44/images/task%206.1.jpg)

Caching stores dependencies between workflow runs.

**First Run Second Run**

![task6.2](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/6c049a7265b2ad380aef1bf9e3911cd64c3fb9fb/2026/day-44/images/task%206.2.jpg)

Example:

pip dependencies cached using actions/cache

This speeds up subsequent pipeline executions.

**What is being cached and where is it stored?**

The dependencies (e.g., pip packages) are cached and stored in GitHub's cache storage. This allows future workflow runs to retrieve the cached dependencies, reducing installation time and speeding up the CI process.


---

# Key Learning

CI pipelines can securely manage secrets, store build outputs, and run automated tests to validate code before deployment.