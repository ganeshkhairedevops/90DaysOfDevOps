# Day 30 – Docker Images & Container Lifecycle

Today I focused on understanding how Docker images and containers work internally, including layers, caching, and the full container lifecycle.

---

# 🐳 Task 1 – Docker Images

## Pull Images

Pulled the following images from Docker Hub:
```bash
docker pull nginx
docker pull ubuntu
docker pull alpine
```
---

## List Images
```bash
docker images
```
Observed:

- ubuntu → 78.1 MB
- alpine → 8.44 MB
- nginx → 161 MB

### Why is Alpine much smaller?

- Alpine uses BusyBox and musl instead of glibc
- Minimal packages
- Designed for lightweight containers
- Smaller attack surface
- Faster download time

Alpine is ideal for production microservices.

---

## Inspect an Image
```bash
docker inspect nginx
```
Provides detailed metadata about the image, including:
- Architecture
- OS
- Created date
- Size
- Layers
- Environment variables
- Exposed ports
- Default command
This information is crucial for debugging and understanding image contents.
---

## Remove an Image
```bash
docker rmi alpine
```
Cannot remove if a container is using it.

---

# 🧱 Task 2 – Image Layers
```bash
docker image history nginx
```
Observed:

- Multiple layers
- Each line represents a layer
- Some layers show size
- Some show 0B


## What Are Layers?

Docker images are built in layers.

Each instruction in a Dockerfile creates a new layer.

Example:

FROM ubuntu

RUN apt update

RUN apt install nginx

Each RUN creates a new layer.

### Why Docker Uses Layers

- Reusability
- Faster builds (layer caching)
- Efficient storage
- Shared layers between images
- Faster pulls

Layer caching improves CI/CD build times significantly.

---

# 🔄 Task 3 – Container Lifecycle

Used one nginx container for lifecycle practice.

---

## Create Container (Without Starting)
```bash
docker create --name lifecycle-nginx nginx
```
Status: Created

---

## Start Container
```bash
docker start lifecycle-nginx
```
Status: Up

---

## Pause Container
```bash
docker pause lifecycle-nginx
```
Status: Paused

---

## Unpause

docker unpause lifecycle-nginx

Status: Running

---

## Stop
```bash
docker stop lifecycle-nginx
```
Status: Exited

---

## Restart
```bash
docker restart lifecycle-nginx
bash
```
---

## kill
```bash
docker kill lifecycle-nginx
```
---

## Remove Container
```bash
docker rm lifecycle-nginx
```
Removed from system.

---

# 🧪 Task 4 – Working with Running Containers

## Run Nginx in Detached Mode
```bash
docker run -d -p 8080:80 --name web nginx
```
---

## View Logs
```bash
docker logs web
```
---

## Follow Logs (Real-Time)
```bash
docker logs -f web
```
---

## Exec into Container
```bash
docker exec -it web bash
```
Explored:
- whoami
- /etc
- /usr/share/nginx/html


---

## Run Single Command Inside Container
```bash
docker exec web ls /
```
Runs command without interactive shell.

---

## Inspect Container
```bash
docker inspect web
```
Found:

- Container IP address
- Port mappings
- Mounted volumes
- Network settings
- Container state

---

# 🧹 Task 5 – Cleanup

## Stop All Running Containers
```bash
docker stop $(docker ps -q)
```
---

## Remove All Stopped Containers
```bash
docker container prune
```
---

## Remove Unused Images
```bash
docker image prune
```
---

## Check Docker Disk Usage
```bash
docker system df
```
Shows:
- Images size
- Containers size
- Volumes size
- Build cache

---

# 🎯 Key Learnings

- Images are templates
- Containers are running instances
- Images are layered
- Layers enable caching and efficient storage
- Containers move through states:
  Created → Running → Paused → Stopped → Removed
- Docker system prune helps free disk space

---

# 🚀 Why This Matters for DevOps

Understanding image layers and lifecycle is critical for:

- Optimizing CI/CD pipelines
- Reducing image size
- Speeding up deployments
- Debugging container failures
- Efficient resource usage
