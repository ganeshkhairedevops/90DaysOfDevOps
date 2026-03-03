# Day 39 – What is CI/CD?

Today I focused on understanding the concepts behind CI/CD before writing any pipelines.

CI/CD is not just tooling — it is a software delivery practice.

---

# Task 1 – The Problem

Imagine 5 developers manually pushing code and deploying to production.

## What can go wrong?

- Code conflicts between developers
- Undetected bugs reaching production
- Environment inconsistencies
- Manual deployment errors
- Rollback difficulty
- No automated testing validation

## What does "It works on my machine" mean?

It means code runs in a developer’s local environment but fails elsewhere due to:
- Different dependencies
- Different OS configurations
- Missing environment variables
- Version mismatches

This is a real problem because production environments must be predictable and reproducible.

## How many times a day can a team safely deploy manually?

Very limited. Manual deployments:
- Are slow
- Increase risk
- Do not scale with team size
A team might safely deploy once a day, but it becomes increasingly risky and inefficient as the team grows.

Automation solves this.

---

# Task 2 – CI vs CD
## Continuous Integration (CI)
CI is the practice of automatically integrating code changes into a shared repository multiple times a day. It includes automated testing to catch bugs early.

Example: A developer pushes code, and a CI pipeline runs tests to validate the changes before merging.

When a developer pushes code, automated tests run and block merging if tests fail.

## Continuous Delivery (CD)
CD extends CI by ensuring that code changes are automatically prepared for release to production. It means the code is always in a deployable state.

After CI passes:
- Code is automatically prepared for release
- Deployment to staging may be automated
- Production release still requires manual approval

Example: After CI tests pass, the code is automatically built and stored as an artifact, ready for deployment.

After tests pass, a Docker image is built and pushed, ready for release.

## Continuous Deployment (CD)
Continuous Deployment goes a step further by automatically deploying every change that passes CI tests directly to production without manual intervention.

Example: After CI tests pass, the code is automatically deployed to production, allowing for rapid and frequent releases.

Companies like Netflix deploy to production many times per day automatically.

---

# Task 3 – Pipeline Anatomy
- **Trigger**: The event that starts the pipeline (e.g., code push, pull request, schedule)
- **Stage**: A logical phase in the pipeline (e.g., build, test, deploy)
- **Job**: A unit of work within a stage (e.g., run tests, build Docker image)
- **Step**: A single command or action within a job (e.g., `npm install`, `docker build`)
- **Runner**: The machine that executes the job (e.g., GitHub-hosted runner, self-hosted server)
- **Artifact**: Output produced by a job that can be used in later stages (e.g., compiled code, Docker image, build package, logs)
---
# Task 4 – Draw a Pipeline

Scenario:
Developer pushes code → app is tested → Docker image built → deployed to staging.

Text-based diagram:
```
Developer Push Code
      ↓
Trigger (GitHub Push Event)
      ↓
Stage 1: Build
    - Install dependencies
    - Compile application
      ↓
Stage 2: Test
    - Run unit tests
      ↓
Stage 3: Package
    - Build Docker image
    - Push to Docker Hub
      ↓
Stage 4: Deploy
    - Pull image on staging server
    - Restart container
```
If any stage fails → pipeline stops.

---
# Task 5 – Explore in the Wild

Repository explored:
https://github.com/tiangolo/fastapi

Location:
.github/workflows/

Observed workflow file:
test.yml

## What triggers it?

The workflow is triggered on:
- push
- pull_request

This means every time code is pushed or a PR is opened, the pipeline runs automatically.

---

## How many jobs does it have?

It contains multiple jobs including:
- Setting up Python
- Installing dependencies
- Running tests
- Code validation checks

---

## What does it do?

From reviewing the workflow:

- Sets up a Python environment
- Installs project dependencies
- Runs automated tests (pytest)
- Performs validation checks

Purpose:
To ensure that new contributions do not break existing functionality before merging into the main branch.

---

## What I Learned

Open-source projects rely heavily on CI pipelines to:

- Automatically validate contributions
- Maintain code quality
- Prevent broken code from entering the main branch
- Reduce manual review overhead

This demonstrates Continuous Integration in action.

---

## Documentation
Create `day-39-cicd-concepts.md` with:
- Your CI vs CD vs CD definitions
- Pipeline anatomy notes
- Your pipeline diagram
- What you found in the open-source repo

---