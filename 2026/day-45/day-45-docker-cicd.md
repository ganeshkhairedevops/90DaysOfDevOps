
# Day 45 – Docker Build & Push in GitHub Actions

Today I built a complete CI/CD pipeline using GitHub Actions that automatically builds a Docker image and pushes it to Docker Hub whenever code is pushed to the repository.

---

## Docker CI/CD Workflow

Workflow file: `.github/workflows/docker-publish.yml`

```yaml
name: Docker Build and Push

on:
  push:
    branches:
      - main
      - "*" # Trigger on all branches to build images with commit SHA tags.

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Repository
        uses: actions/checkout@v4

      - name: Set short commit SHA
        id: vars
        run: echo "SHORT_SHA=$(echo $GITHUB_SHA | cut -c1-7)" >> $GITHUB_ENV

      - name: build docker image
        run: |
          docker build -t ${{ secrets.DOCKER_USERNAME }}/github-action-app:latest ./app
          docker build -t ${{ secrets.DOCKER_USERNAME }}/github-action-app:sha-$SHORT_SHA ./app

      - name: Log in to Docker Hub
        if: github.ref == 'refs/heads/main' # Only log in on main branch to push images
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_TOKEN }}

      - name: Push Docker Image
        if: github.ref == 'refs/heads/main' # Only push on main branch
        run: |
          docker push ${{ secrets.DOCKER_USERNAME }}/github-action-app:latest
          docker push ${{ secrets.DOCKER_USERNAME }}/github-action-app:sha-$SHORT_SHA
```
## Task 1: Prepare

![task1](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/8e91f2f5d4a7f94d32e7ab7315cbfc4d8f05b16a/2026/day-45/images/task%201.jpg)

## GitHub Secrets Used

| Secret | Purpose |
|------|------|
| DOCKER_USERNAME | Docker Hub username |
| DOCKER_TOKEN | Docker Hub access token |

Secrets allow authentication without exposing credentials inside the repository.

## Task 2: Build the Docker Image in CI

Does the image build successfully?

Yes,image build successfully

![task2](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/8e91f2f5d4a7f94d32e7ab7315cbfc4d8f05b16a/2026/day-45/images/task%202.jpg)

---

## Task 3: Push to Docker Hub

![task3](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/8e91f2f5d4a7f94d32e7ab7315cbfc4d8f05b16a/2026/day-45/images/task%203.jpg)

Is your image there with both tags?
- Yes

Push latest image

![task3.1](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/8e91f2f5d4a7f94d32e7ab7315cbfc4d8f05b16a/2026/day-45/images/task%203.1.jpg)

Push both images

![task3.2](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/8e91f2f5d4a7f94d32e7ab7315cbfc4d8f05b16a/2026/day-45/images/task%203.2.jpg)

---
## Task 4: Only Push on Main
When push other brach only run and dont push.
On the test branch, the image was built and the push step was skipped.

![task4](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/8e91f2f5d4a7f94d32e7ab7315cbfc4d8f05b16a/2026/day-45/images/task%204.jpg)

Task 5: Add a Status Badge

![task5](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/8e91f2f5d4a7f94d32e7ab7315cbfc4d8f05b16a/2026/day-45/images/task%205.jpg)

---

Task 6: Pull and Run It

Pull image:

```
docker pull ganeshkhaire14/github-action-app:latest
```

Run container:

```
docker run -p 5000:5000 ganeshkhaire14/github-action-app:latest
```
![task6](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/8e91f2f5d4a7f94d32e7ab7315cbfc4d8f05b16a/2026/day-45/images/task%206.jpg)

Docker image live on Docker Hub

![task6.1](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/8e91f2f5d4a7f94d32e7ab7315cbfc4d8f05b16a/2026/day-45/images/task%206.1.jpg)

---

## Full Journey: From Git Push to Running Container

1. Developer pushes code to GitHub.
2. GitHub Actions workflow starts automatically.
3. Runner checks out the repository.
4. Docker image is built using the Dockerfile.
5. GitHub logs into Docker Hub using repository secrets.
6. Image is tagged with `latest` and commit SHA.
7. Image is pushed to Docker Hub.
8. Any machine can pull the image.
9. Container runs using `docker run`.

---

## Key Learning

CI/CD pipelines automate building, packaging, and publishing container images. This allows applications to be deployed consistently across environments using Docker images stored in registries like Docker Hub.
