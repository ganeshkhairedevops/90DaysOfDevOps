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

![docker images](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/87006bdd3883ab13c7f8d2d679df0d31adb0b9fd/2026/day-30/images/task%201.jpg)

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
![docker remove](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/87006bdd3883ab13c7f8d2d679df0d31adb0b9fd/2026/day-30/images/task%201.1.jpg)

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

![image history](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/87006bdd3883ab13c7f8d2d679df0d31adb0b9fd/2026/day-30/images/task%202.jpg)

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

![create](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/87006bdd3883ab13c7f8d2d679df0d31adb0b9fd/2026/day-30/images/task%203.jpg)
---

## Start Container
```bash
docker start lifecycle-nginx
```
Status: Up

![docker start](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/87006bdd3883ab13c7f8d2d679df0d31adb0b9fd/2026/day-30/images/task%203.1.jpg)

---

## Pause Container
```bash
docker pause lifecycle-nginx
```
Status: Paused
![docker pause](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/87006bdd3883ab13c7f8d2d679df0d31adb0b9fd/2026/day-30/images/task%203.2.jpg)

---

## Unpause

docker unpause lifecycle-nginx

Status: Running

![docker unpause](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/87006bdd3883ab13c7f8d2d679df0d31adb0b9fd/2026/day-30/images/task%203.3.jpg)

---

## Stop
```bash
docker stop lifecycle-nginx
```
Status: Exited

![docker stop](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/87006bdd3883ab13c7f8d2d679df0d31adb0b9fd/2026/day-30/images/task%203.4.jpg)

---

## Restart
```bash
docker restart lifecycle-nginx
bash
```
![docker restart](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/87006bdd3883ab13c7f8d2d679df0d31adb0b9fd/2026/day-30/images/task%203.5.jpg)

---

## kill
```bash
docker kill lifecycle-nginx
```
![docker kill](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/87006bdd3883ab13c7f8d2d679df0d31adb0b9fd/2026/day-30/images/task%203.6.jpg)

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
![docker logs](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/87006bdd3883ab13c7f8d2d679df0d31adb0b9fd/2026/day-30/images/task%204.jpg)

---

## Follow Logs (Real-Time)
```bash
docker logs -f web
```
![docker logs f](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/87006bdd3883ab13c7f8d2d679df0d31adb0b9fd/2026/day-30/images/task%204.1.jpg)

---

## Exec into Container
```bash
docker exec -it web bash
```
Explored:
- whoami
- /etc
- /usr/share/nginx/html

![docker exec](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/87006bdd3883ab13c7f8d2d679df0d31adb0b9fd/2026/day-30/images/task%204.2.jpg)

---

## Run Single Command Inside Container
```bash
docker exec web ls /
```
Runs command without interactive shell.
![docker exec inside](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/87006bdd3883ab13c7f8d2d679df0d31adb0b9fd/2026/day-30/images/task%204.3.jpg)

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

![inspect](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/87006bdd3883ab13c7f8d2d679df0d31adb0b9fd/2026/day-30/images/task%204.4.jpg)


![inspect network](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/87006bdd3883ab13c7f8d2d679df0d31adb0b9fd/2026/day-30/images/task%204.5.jpg)

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

![docker cleanup](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/87006bdd3883ab13c7f8d2d679df0d31adb0b9fd/2026/day-30/images/task%205.jpg)

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
