# Day 43 – Jobs, Steps, Environment Variables & Conditionals

Today I learned how to control workflow execution using multi-job pipelines, environment variables, job outputs, and conditionals.

---

# Task 1: Multi Job Workflow

Created a workflow with three jobs:

build → test → deploy

Workflow file: `.github/workflows/multi-job.yml`
```yml
name: Multi Job Pipeline

on:
  push:

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Build Step
        run: echo "Building the app"

  test:
    runs-on: ubuntu-latest
    needs: build
    steps:
      - name: Test Step
        run: echo "Running tests"

  deploy:
    runs-on: ubuntu-latest
    needs: test
    steps:
      - name: Deploy Step
        run: echo "Deploying"
```
This ensures the test job runs only after build succeeds.

![task1]()

**Does it show the dependency chain?**

Yes, the `needs` keyword creates a dependency chain between jobs. In this case, the `test` job will only execute after the `build` job has successfully completed. Similarly, if you have a `deploy` job that also uses `needs: test`, it will only run after the `test` job has succeeded. This allows you to control the flow of your CI/CD pipeline and ensure that each step is executed in the correct order based on the success of previous steps.

---

# Task 2: Environment Variables
Workflow file: `.github/workflows/env-vars.yml`
```yml
name: Environment Variables


on:
  push:

env:
  APP_NAME: myapp

jobs:
  show-env:
    runs-on: ubuntu-latest
    env:
      ENVIRONMENT: staging

    steps:
      - name: Print variables
        env:
          VERSION: 1.0.0
        run: |
          echo "App: $APP_NAME"
          echo "Environment: $ENVIRONMENT"
          echo "Version: $VERSION"
          echo "Commit SHA: ${{ github.sha }}"
          echo "Triggered by: ${{ github.actor }}"
```
Used environment variables at three levels:

Workflow level:
APP_NAME=myapp

Job level:
ENVIRONMENT=staging

Step level:
VERSION=1.0.0

Also printed GitHub context variables:

github.sha
github.actor

![task2]()

---

# Task 3: Job Outputs
Workflow file: `.github/workflows/job-output.yml`
```yml
name: Job Output

on:
  push:

jobs:
  generate-date:
    runs-on: ubuntu-latest
    outputs:
      today: ${{ steps.date-step.outputs.today }}

    steps:
      - name: Generate date
        id: date-step
        run: echo "today=$(date)" >> $GITHUB_OUTPUT

  use-date:
    runs-on: ubuntu-latest
    needs: generate-date

    steps:
      - name: Print date from previous job
        run: echo "Today's date is ${{ needs.generate-date.outputs.today }}"
```
Created a job that generates today's date and passes it to another job using:

outputs:
needs.<job>.outputs.<name>

This allows jobs to share data across workflow stages.

Example uses:
- build version numbers
- artifact paths
- Docker image tags

![task3]()

Why would you pass outputs between jobs?
Passing outputs between jobs allows you to share data generated in one job with subsequent jobs in the workflow. This is useful for scenarios where you need to:
- Build version numbers in a build job and use them in a deploy job.
- Generate artifact paths in a build job and reference them in a test or deploy job.
- Create Docker image tags in a build job and use them in a deploy job.
By using outputs, you can create more dynamic and flexible workflows that can adapt based on the results of previous jobs, enabling better automation and efficiency in your CI/CD processes.

---

# Task 4: Conditionals
Workflow file: `.github/workflows/conditionals.yml`
```yml
name: Conditional Workflow

on:
  push:
  pull_request:

jobs:
  conditional-demo:
    runs-on: ubuntu-latest

    steps:
      - name: Always run
        run: echo "This always runs"

      - name: Run only on main branch
        if: github.ref == 'refs/heads/main'
        run: echo "Running on main branch"

      - name: Fail step intentionally
        id: fail-step
        run: exit 1
        continue-on-error: true

      - name: Run only if previous step failed
        if: failure()
        run: echo "Previous step failed!"
```
Used conditional execution with:

if: github.ref == 'refs/heads/main'

Also used:

continue-on-error: true

This allows the pipeline to continue even if a step fails.

![task4]()
**A step with continue-on-error: true — what does this do?**

The `continue-on-error: true` setting allows a step to fail without causing the entire job or workflow to fail. When this option is set, if the step encounters an error, it will be marked as failed, but the workflow will continue executing the subsequent steps or jobs. This can be useful in scenarios where you want to allow certain non-critical steps to fail without impacting the overall success of the workflow, such as running optional tests or performing cleanup tasks that may not be essential for the main functionality of the pipeline.


---

# Task 5: Putting It Together
Workflow file: `.github/workflows/smart-pipeline.yml`
```yml
name: Smart Pipeline

on:
  push:

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - run: echo "Running lint checks"

  test:
    runs-on: ubuntu-latest
    steps:
      - run: echo "Running tests"

  summary:
    runs-on: ubuntu-latest
    needs: [lint, test]

    steps:
      - name: Print branch type
        run: |
          if [[ "${{ github.ref }}" == "refs/heads/main" ]]; then
            echo "Main branch push detected"
          else
            echo "Feature branch push detected"
          fi

      - name: Print commit message
        run: |
          echo "Commit message: ${{ github.event.head_commit.message }}"
```
This workflow runs lint and test jobs in parallel, then a summary job that uses conditionals to print different messages based on the branch type.

![task5]()

# Key Learning

GitHub Actions workflows can be controlled using:

jobs

steps

environment variables

outputs

conditional execution

This allows building more intelligent CI/CD pipelines.