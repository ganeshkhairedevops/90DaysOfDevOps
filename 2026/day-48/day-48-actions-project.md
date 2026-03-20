# Day 48 – GitHub Actions Capstone Project

## Overview
End-to-end CI/CD pipeline with:
- PR pipeline (test only)
- Main pipeline (build → docker → deploy)
- Scheduled health checks

## Architecture
PR → Build & Test → Merge → Docker Build → Deploy → Health Check

## Workflows
- reusable-build-test.yml
- reusable-docker.yml
- pr-pipeline.yml
- main-pipeline.yml
- health-check.yml

---
## Task 1: Set Up the Project Repo
- Create GitHub repo
- Add application code
- Add Dockerfile
- Add GitHub Actions workflows

## Task 2: Reusable Workflow — Build & Test
- Build and test application
- Reusable workflow for PR and main pipelines

Create `.github/workflows/reusable-build-test.yml`:
```yml
name: Reusable Build & Test

on:
  workflow_call:
    inputs:
      node_version:
        description: "Node.js version"
        required: true
        type: string
      run_tests:
        description: "Run tests or not"
        required: false
        type: boolean
        default: true
    outputs:
      test_result:
        description: "Result of test execution"
        value: ${{ jobs.build.outputs.result }}

jobs:
  build:
    runs-on: ubuntu-latest

    outputs:
      result: ${{ steps.set-result.outputs.result }}

    steps:
      - name: Checkout Code
        uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: ${{ inputs.node_version }}

      - name: Install Dependencies
        run: npm install

      - name: Start App
        run: |
          npm start &
          sleep 5

      - name: Run Tests (Health Check)
        if: ${{ inputs.run_tests }}
        run: |
          curl -f http://localhost:3000/health || exit 1

      - name: Set Test Result (Passed)
        id: set-result
        if: success()
        run: echo "result=passed" >> $GITHUB_OUTPUT

      - name: Set Test Result (Failed)
        if: failure()
        run: echo "result=failed" >> $GITHUB_OUTPUT
```
![task1](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/832e492dd110ecb7a5b8bc7f319d36130fbe02c0/2026/day-48/images/task%201.jpg)

![task2](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/832e492dd110ecb7a5b8bc7f319d36130fbe02c0/2026/day-48/images/task%202.jpg)

## Task 3: Reusable Workflow — Docker Build & Push
- Build and push Docker image to Docker Hub
Create `.github/workflows/reusable-docker.yml`:
```yml
name: Reusable Docker Build & Push

on:
  workflow_call:
    inputs:
      image_name:
        description: "Docker image name (e.g., username/app)"
        required: true
        type: string
      tag:
        description: "Docker image tag"
        required: true
        type: string
    secrets:
      docker_username:
        required: true
        description: 'Docker Hub username'
      docker_token:
        required: true
        description: 'Docker Hub token'
    outputs:
      image_url:
        description: "Full Docker image URL"
        value: ${{ jobs.docker.outputs.image_url }}

jobs:
  docker:
    name: Docker Build & Push
    runs-on: ubuntu-latest

    outputs:
      image_url: ${{ steps.set-image-url.outputs.image_url }}

    steps:
      - name: Checkout Code
        uses: actions/checkout@v4

      - name: Login to Docker Hub
        run: |
          echo "${{ secrets.docker_token }}" | docker login -u "${{ secrets.docker_username }}" --password-stdin

      - name: Build Docker Image
        run: |
          docker build -t ${{ inputs.image_name }}:${{ inputs.tag }} .
          docker build -t ${{ inputs.image_name }}:latest .

      - name: Push Docker Image
        run: |
          docker push ${{ inputs.image_name }}:${{ inputs.tag }}
          docker push ${{ inputs.image_name }}:latest

      - name: Set Image Output
        id: set-image
        run: echo "image_url=${{ inputs.image_name }}:${{ inputs.tag }}" >> $GITHUB_OUTPUT
```

## Task 4: PR Pipeline
```yml
name: PR Pipeline

on:
  pull_request:
    branches:
      - main
    types:
      - opened
      - synchronize

jobs:
  build-test:
    name: Build & Test (Reusable)
    uses: ./.github/workflows/reusable-build-test.yml
    with:
      node_version: "18"
      run_tests: true

  pr-summary:
    name: PR Summary
    runs-on: ubuntu-latest
    needs: build-test

    steps:
      - name: Print PR Summary
        run: |
          echo "PR checks passed for branch: ${{ github.head_ref }}"
          echo "PR Title: ${{ github.event.pull_request.title }}"
          echo "Author: ${{ github.event.pull_request.user.login }}"
          echo " Commit: ${{ github.sha }}"
```
![task4](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/832e492dd110ecb7a5b8bc7f319d36130fbe02c0/2026/day-48/images/task%204.jpg)

![task4.1](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/832e492dd110ecb7a5b8bc7f319d36130fbe02c0/2026/day-48/images/task%204.1.jpg)
## Task 5: Main Pipeline
Create `.github/workflows/main-pipeline.yml:`
```yml
name: Main Pipeline

on:
  push:
    branches:
      - main

jobs:
  build-test:
    name: Build & Test
    uses: ./.github/workflows/reusable-build-test.yml
    with:
      node_version: "18"
      run_tests: true

  docker:
    name: Docker Build & Push
    needs: build-test
    uses: ./.github/workflows/reusable-docker.yml
    with:
      image_name: ganeshkhaire14/node-app-github-actions
    secrets:
      docker_username: ${{ secrets.docker_username }}
      docker_token: ${{ secrets.docker_token }}

  deploy:
    name: Deploy to Production
    needs: docker
    runs-on: ubuntu-latest
    environment: production

    steps:
      - name: Deploy image to production
        run: |
          echo "Deploying image: ${{ needs.docker.outputs.image_url }} to production"
```

![task1](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/832e492dd110ecb7a5b8bc7f319d36130fbe02c0/2026/day-48/images/task%205.jpg)

![task5.1](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/832e492dd110ecb7a5b8bc7f319d36130fbe02c0/2026/day-48/images/task%205.1.jpg)


## Task 6: Scheduled Health Check
Create `.github/workflows/health-check.yml:`
```yml
name: Health Check

on:
  schedule:
    - cron: '0 */12 * * *' # Every 12 hours 
  workflow_dispatch:         # Manual trigger

jobs:
  health-check:
    runs-on: ubuntu-latest

    steps:
      - name: Pull Latest Docker Image
        run: docker pull ganeshkhaire14/node-app-github-actions:latest

      - name: Run Container
        run: docker run -d -p 3000:3000 --name app ganeshkhaire14/node-app-github-actions:latest

      - name: Wait for App to Start
        run: sleep 5

      - name: Health Check (curl)
        id: health
        run: |
          STATUS=$(curl -o /dev/null -s -w "%{http_code}" http://localhost:3000/health)
          echo "HTTP Status: $STATUS"
          
          if [ "$STATUS" -eq 200 ]; then
            echo "status=PASSED" >> $GITHUB_OUTPUT
          else
            echo "status=FAILED" >> $GITHUB_OUTPUT
            exit 1
          fi

      - name: Stop and Remove Container
        if: always()
        run: docker rm -f app

      - name: Generate Summary
        if: always()
        run: |
          echo "## Health Check Report" >> $GITHUB_STEP_SUMMARY
          echo "- Image: ganeshkhaire14/node-app-github-actions:latest" >> $GITHUB_STEP_SUMMARY
          echo "- Status: ${{ steps.health.outputs.status }}" >> $GITHUB_STEP_SUMMARY
          echo "- Time: $(date)" >> $GITHUB_STEP_SUMMARY
```
![task6](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/832e492dd110ecb7a5b8bc7f319d36130fbe02c0/2026/day-48/images/task%206.jpg)

### Task 7: Add Badges & Documentation
- Add workflow badges to README

**Add Trivy Scan**

found vulnerability

![task7](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/832e492dd110ecb7a5b8bc7f319d36130fbe02c0/2026/day-48/images/task%207.jpg)

solve issue

![task7.1](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/832e492dd110ecb7a5b8bc7f319d36130fbe02c0/2026/day-48/images/task%207.1.jpg)


