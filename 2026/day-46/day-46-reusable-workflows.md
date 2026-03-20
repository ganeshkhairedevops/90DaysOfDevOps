# Day 46 – Reusable Workflows & Composite Actions

In real DevOps environments, workflows are not written repeatedly for every repository. Instead, reusable workflows and composite actions allow teams to standardize CI/CD processes and reuse automation across multiple repositories.

This exercise demonstrates:

Creating a Reusable Workflow

Calling it from another workflow

Passing inputs and secrets

Returning outputs

Creating a Custom Composite Action

## Task 1 – Understanding workflow_call

**What is a Reusable Workflow?**

A Reusable Workflow is a GitHub Actions workflow that can be called from another workflow.
It allows teams to reuse CI/CD logic across repositories without rewriting the same workflow.

Benefits:

Standardized CI/CD pipelines

Reduced duplication

Easier maintenance

Centralized automation

**What is the workflow_call trigger?**

workflow_call is a special trigger that allows a workflow to be executed by another workflow.

Example:

on:
  workflow_call:

This means the workflow cannot run directly from push or PR events.
It only runs when another workflow calls it.

**How is calling a reusable workflow different from using a regular action (uses:)?**

When you call a reusable workflow, you use the workflow_call trigger and specify the path to the reusable workflow file.

When you use a regular action, you specify the action repository and version.

**Where Must a Reusable Workflow Live?**

A reusable workflow must be defined in the same repository or in a public repository that can be accessed by the calling workflow.
It cannot be defined in a private repository unless the calling workflow has access to it.

Reusable workflows must be stored in:
```
.github/workflows/
```
---
## Task 2 – Creating a Reusable Workflow
Create `.github/workflows/reusable-build.yml:`
```yml
name: Reusable Build Workflow

on:
  workflow_call:
    inputs:
      app_name:
        required: true
        type: string
      environment:
        required: false
        type: string
        default: staging

    secrets:
      docker_token:
        required: true

    outputs:
      build_version:
        description: "Generated build version"
        value: ${{ jobs.build.outputs.build_version }}

jobs:
  build:
    runs-on: ubuntu-latest

    outputs:
      build_version: ${{ steps.version.outputs.version }}

    steps:
      - name: Checkout Repository
        uses: actions/checkout@v4

      - name: Print Build Info
        run: |
          echo "Building ${{ inputs.app_name }} for ${{ inputs.environment }}"

      - name: Verify Docker Token
        run: |
          echo "Docker token is set: ${{ secrets.docker_token != '' }}"

      - name: Generate Build Version
        id: version
        run: |
          VERSION="v1.0-${GITHUB_SHA::7}"
          echo "version=$VERSION" >> $GITHUB_OUTPUT
```
![task](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/9663cbacb557276f4ba666b2ab565bcfcaac213e/2026/day-46/images/task%202.jpg)

This workflow defines a reusable build process that accepts inputs for the application name and environment, requires a Docker token secret, and outputs a generated build version.

---

## Task 3 – Calling the Reusable Workflow
Create `.github/workflows/call-build.yml:`
```yml
name: Call Reusable Build

on:
  push:
    branches:
      - main

jobs:
  build:
    uses: ./.github/workflows/reusable-build.yml

    with:
      app_name: "my-web-app"
      environment: "production"

    secrets:
      docker_token: ${{ secrets.DOCKER_TOKEN }}

  print-version:
    needs: build
    runs-on: ubuntu-latest

    steps:
      - name: Print Build Version
        run: |
          echo "Build version is: ${{ needs.build.outputs.build_version }}"
```
![task3](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/9663cbacb557276f4ba666b2ab565bcfcaac213e/2026/day-46/images/task%203.jpg)

This workflow triggers on pushes to the main branch, calls the reusable build workflow, and then prints the generated build version.

## Task 4: Add Outputs to the Reusable Workflow
In the reusable workflow (`reusable-build.yml`), we already defined an output for the build version
```yml
outputs:
  build_version:
    description: "Generated build version"
    value: ${{ jobs.build.outputs.build_version }}
```
![task4](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/9663cbacb557276f4ba666b2ab565bcfcaac213e/2026/day-46/images/task%204.jpg)

This allows the calling workflow to access the generated build version after the reusable workflow completes.
In the calling workflow (`call-build.yml`), we can access this output using:
```yml
echo "Build version is: ${{ needs.build.outputs.build_version }}"
```
This demonstrates how to return outputs from a reusable workflow and use them in the calling workflow.
---
## Task 5: Create a Custom Composite Action
A Composite Action allows you to combine multiple steps into a single reusable action.

**Does your custom action run and print the greeting?**
 
Yes,custom action run and print the greeting

![task5](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/9663cbacb557276f4ba666b2ab565bcfcaac213e/2026/day-46/images/task%205.jpg)

---

### Task 6: Reusable Workflow vs Composite Action
Fill this in your notes:

| | Reusable Workflow | Composite Action |
|---|---|---|
| Triggered by | `workflow_call` | `uses:` in a step |
| Can contain jobs? | Yes | No |
| Can contain multiple steps? | Yes | Yes |
| Lives where? | .github/workflows/ | .github/actions/ |
| Can accept secrets directly? | Yes | No |
| Best for | Reusing full workflows| Reusing small step groups |

