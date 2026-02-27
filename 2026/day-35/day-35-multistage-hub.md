# Day 35 – Multi-Stage Builds & Docker Hub

Today I optimized Docker images using multi-stage builds and pushed them to Docker Hub.

---

## Task 1: Problem: Large Images

Built a single-stage Node image.
Image size: ~1.9 GB

![docker image](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/53d92ebbfdb0055b6a6f8e314b905bad8e0f9321/2026/day-35/images/task%201.JPG)

Reason:
- Includes build tools
- Full OS
- Unnecessary dependencies

## Task 2: Solution: Multi-Stage Build

Used two stages:
1. Builder stage
2. Production stage (node:18-alpine)

Final image size: ~127MB

Reduced size significantly.

![Multistage](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/53d92ebbfdb0055b6a6f8e314b905bad8e0f9321/2026/day-35/images/task%202.JPG)

## Why is the multi-stage image so much smaller?
- The production stage only copies the necessary files (built app) from the builder stage.
- It uses a lightweight base image (alpine) that has a smaller footprint.
- Build tools and dependencies are not included in the final image.
---
## Task 3: Push to Docker Hub
1. Logged in via terminal, get a Docker Hub Personal Access Token (PAT)

- Go to Docker Hub → Security → Access Tokens.
- Click New Access Token.
- Give it a name, click Generate, and copy the token.

Log in via CLI

For Example:
```bash
docker login -u ganeshkhaire14
```
and pest access token.

Login Succeeded

2. Tagged the image with my Docker Hub username.

```bash
docker tag node_multistage:v1 ganeshkhaire14/node-multistage:v1
```
![docker tag](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/53d92ebbfdb0055b6a6f8e314b905bad8e0f9321/2026/day-35/images/task%203.JPG)

3. Pushed the image to Docker Hub.

```bash
docker push ganeshkhaire14/node-multistage:v1
```
![docker hub](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/53d92ebbfdb0055b6a6f8e314b905bad8e0f9321/2026/day-35/images/task%203.1.jpg)

Now anyone can pull my optimized image using:

4. remove image form locally 
```bash
docker rmi ganeshkhaire14/node-multistage:v1
```
5. pull image again
```bash
docker pull ganeshkhaire14/node-multistage:v1
```
![docker pull](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/53d92ebbfdb0055b6a6f8e314b905bad8e0f9321/2026/day-35/images/task%203.2.JPG)

---

## Task 4: Docker Hub Repository

Add a description to the repository
- Go to Docker Hub → Repositories → Your Repository → Edit.
- Add a description, click Save.

![task 4](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/53d92ebbfdb0055b6a6f8e314b905bad8e0f9321/2026/day-35/images/task%204.jpg)

---

## Task 5: Image Best Practices
- Use official base images when possible.
- Keep images small by only including necessary files and dependencies.
- Use multi-stage builds to separate build and runtime environments.
- Regularly update base images to get security patches.
- Use .dockerignore to exclude unnecessary files from the build context.
- Tag images with meaningful version numbers.
- Avoid running processes as root inside the container.

---
## Conclusion
Multi-stage builds are essential for creating optimized Docker images. They allow us to separate the build environment from the runtime environment, resulting in smaller, more secure images. Pushing to Docker Hub makes it easy to share our images with others and deploy them across different environments. By following best practices, we can ensure our images are efficient and maintainable.

