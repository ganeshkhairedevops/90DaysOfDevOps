# Day 31 – Dockerfile: Build Your Own Images

Today I learned how to write Dockerfiles and build custom Docker images.

This marks the transition from just running containers to actually creating production-ready images.

---

# 🧱 Task 1 – My First Dockerfile

## Project Structure

my-first-image/
│
└── Dockerfile

---

## Dockerfile

FROM ubuntu:latest

RUN apt update && apt install -y curl

CMD ["echo", "Hello from my custom image!"]

---

## Build Image
```bash
docker build -t my-ubuntu:v1 .
```
---

## Run Container
```bash
docker run my-ubuntu:v1
```
Output:
Hello from my custom image!

Verified successfully.

---

# 📦 Task 2 – Dockerfile Instructions

## Project Structure

dockerfile-demo/
│
├── Dockerfile
└── app.txt

---

## app.txt

This file was copied during build.

---

## Dockerfile

FROM ubuntu:latest

WORKDIR /app

COPY app.txt /app/

RUN apt update && apt install -y curl

EXPOSE 8080

CMD ["cat", "app.txt"]

---

## What Each Instruction Does

FROM → Defines base image  
WORKDIR → Sets working directory inside container  
COPY → Copies files from host to image  
RUN → Executes commands during build  
EXPOSE → Documents the port the container uses  
CMD → Default command when container starts  

---

# ⚖ Task 3 – CMD vs ENTRYPOINT

## Dockerfile with CMD

FROM ubuntu

CMD ["echo", "hello"]

```bash
docker build -t cmd-test .
```
```bash
docker run cmd-test
```
Output:
hello
```bash
docker run cmd-test echo custom
```
Output:
custom

CMD is overridden by arguments passed at runtime.
When you provide a command at runtime, Docker overrides the CMD instruction completely.

---

## Dockerfile with ENTRYPOINT

FROM ubuntu

ENTRYPOINT ["echo"]
```bash
docker build -t entrypoint-test .
```
```bash
docker run entrypoint-test hello
```
Output:
hello
```bash
docker run entrypoint-test world
```
Output:
world

ENTRYPOINT cannot be overridden easily — it always runs.

---

## When to Use CMD vs ENTRYPOINT

Use CMD:
- When you want default behavior
- Allow users to override commands

Use ENTRYPOINT:
- When container should always behave like a specific executable
- For CLI-style containers

---

# 🌐 Task 4 – Simple Web App Image

## index.html

<h1>Welcome to My Docker Website</h1>

---

## Dockerfile

FROM nginx:alpine

COPY index.html /usr/share/nginx/html/

---

## Build Image

docker build -t my-website:v1 .

---

## Run Container

docker run -d -p 85:80 my-website:v1

Access:
http://localhost:85/index.html

Verified custom webpage loads successfully.

---

# 🚫 Task 5 – .dockerignore

Created .dockerignore:

node_modules
.git
.env

Build verified that ignored files were not copied.

This reduces image size and improves security.

---

# 🚀 Task 6 – Build Optimization

Observed:

- Docker caches layers.
- If a layer doesn't change, it uses cache.
- If a layer changes, all layers after it rebuild.

Example:

Better order:

FROM ubuntu

RUN apt update && apt install -y curl

COPY app.txt .


Instead of:

FROM ubuntu

COPY app.txt .

RUN apt update && apt install -y curl

Because frequently changing files should be copied later.

---

## Why does layer order matter for build speed?
Layer order matters because Docker builds images in layers. If a layer changes, all subsequent layers must be rebuilt. By placing frequently changing instructions (like COPY) towards the end of the Dockerfile, you can take advantage of caching for earlier layers, significantly improving build speed and efficiency.

## Why Layer Order Matters

- Improves build speed
- Reduces unnecessary rebuilds
- Optimizes CI/CD pipelines
- Saves storage

---

# 🎯 Key Learnings

- Dockerfiles define how images are built
- Every instruction creates a layer
- CMD can be overridden
- ENTRYPOINT enforces execution behavior
- .dockerignore reduces build context
- Layer ordering affects build performance

---

# 🚀 Why This Matters for DevOps

Dockerfiles are essential for:

- CI/CD automation
- Microservices deployment
- Cloud-native applications
- Kubernetes workloads

Now I can build custom container images — not just run existing ones.