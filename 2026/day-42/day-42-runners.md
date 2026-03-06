# Day 42 – GitHub Actions Runners

Today I learned about GitHub-hosted runners and how to configure my own self-hosted runner.

---

# Task 1: GitHub Hosted Runners

Workflow file: `.github/workflows/hosted-runners.yml`
```yaml
name: Hosted Runners

on:
  push:

jobs:
  ubuntu-job:
    runs-on: ubuntu-latest
    steps:
      - name: Print runner details
        run: |
          echo "OS: $RUNNER_OS"
          hostname
          whoami

  windows-job:
    runs-on: windows-latest
    steps:
      - name: Print runner details
        run: |
          echo OS: %RUNNER_OS%
          hostname
          whoami

  macos-job:
    runs-on: macos-latest
    steps:
      - name: Print runner details
        run: |
          echo "OS: $RUNNER_OS"
          hostname
          whoami
```

**What is a GitHub-hosted runner?**
GitHub-hosted runners are virtual machines provided and managed by GitHub.

They run workflows automatically and come pre-installed with many development tools.

Examples:

ubuntu-latest  
windows-latest  
macos-latest  

These runners are created for each workflow run and destroyed afterward.

**Who manages it?**
GitHub manages the infrastructure, maintenance, and updates of these runners.

![task1](
)

![task1.1]()

---

# Task 2: Preinstalled Tools
Workflow file: `.github/workflows/hosted-runners.yml`
```yaml
name: Hosted Runners

on:
  push:

jobs:
  ubuntu-job:
    runs-on: ubuntu-latest
    steps:
      - name: Print runner details
        run: |
          echo "OS: $RUNNER_OS"
          hostname
          whoami

  windows-job:
    runs-on: windows-latest
    steps:
      - name: Print runner details
        run: |
          echo OS: %RUNNER_OS%
          hostname
          whoami

  macos-job:
    runs-on: macos-latest
    steps:
      - name: Print runner details
        run: |
          echo "OS: $RUNNER_OS"
          hostname
          whoami

  check-tools:
    runs-on: ubuntu-latest

    steps:
      - name: Check Docker version
        run: docker --version

      - name: Check Python version
        run: python --version

      - name: Check Node version
        run: node --version

      - name: Check Git version
        run: git --version
```

On the ubuntu-latest runner I checked:

Docker
Python
Node
Git

![task2]()

**Why does it matter that runners come with tools pre-installed?**

Pre-installed tools allow developers to quickly set up CI/CD pipelines without worrying about installing dependencies.
This speeds up development and reduces setup time for workflows.

---

# Task 3: Self Hosted Runner

I configured a self-hosted runner on my own machine using the setup script provided by GitHub.

**Download self-hosted runner**
```bash
# Create a folder
$ mkdir actions-runner && cd actions-runner# Download the latest runner package
$ curl -o actions-runner-linux-x64-2.332.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.332.0/actions-runner-linux-x64-2.332.0.tar.gz# Optional: Validate the hash
$ echo "f2094522a6b9afeab07ffb586d1eb3f190b6457074282796c497ce7dce9e0f2a  actions-runner-linux-x64-2.332.0.tar.gz" | shasum -a 256 -c# Extract the installer
$ tar xzf ./actions-runner-linux-x64-2.332.0.tar.gz
```
![task3]()

**Configure**
```bash
# Create the runner and start the configuration experience
$ ./config.sh --url https://github.com/ganeshkhairedevops/github-actions-practice --token ******************# Last step, run it!
$ ./run.sh
```
![task3.1]()

**Using your self-hosted runner**
```yaml
# Use this YAML in your workflow file for each job
runs-on: self-hosted
```
After starting the runner using:

./run.sh

It appeared in the repository runner list with a green "Idle" status.

![task3.2]()

---

# Task 4: Workflow Running on Self Hosted Runner
Workflow file: `.github/workflows/self-hosted.yml`
```yaml
name: Self Hosted Runner

on:
  push:

jobs:
  run-on-self-hosted:
    runs-on: self-hosted

    steps:
      - name: Show hostname
        run: hostname

      - name: Show working directory
        run: pwd

      - name: Create test file
        run: |
          echo "Hello from self hosted runner" > runner-test.txt
          ls -la
```

The workflow printed the hostname of my machine and created a file during execution.
![task4]()

The file confirmed that the job was executed on my own server.

![task4.1]()

---

# Task 5: Runner Labels

I added a label to the runner:

my-linux-runner

This allows workflows to target specific runners using:

runs-on: [self-hosted, my-linux-runner]

Labels are useful when managing multiple runners.

![task5]()

---

# GitHub Hosted vs Self Hosted

| Feature | GitHub Hosted | Self Hosted |
|------|------|------|
| Managed by | GitHub | User |
| Cost | Free minutes / paid after limit | Cost of server |
| Pre-installed tools | Yes | User installs |
| Good for | Quick CI pipelines | Custom environments |
| Security concern | Lower | Must secure your own server |

---

# Key Learning

Runners are the machines that execute CI/CD jobs.

GitHub-hosted runners are easy to use, while self-hosted runners provide more control and customization.

Self-hosted runners require maintenance and security considerations.

