# Day 29 – Introduction to Docker

Today I started learning Docker — the foundation of modern DevOps and containerized deployments.

---

# 🐳 Task 1 – What is Docker?

## What is a Container?

A container is a lightweight, portable unit that packages an application along with its dependencies, libraries, and runtime.

Containers ensure that:
- The application runs the same in development and production
- There are no “it works on my machine” issues
- Environments are consistent across teams

---

## Containers vs Virtual Machines

| Containers | Virtual Machines |
|------------|------------------|
| Share host OS kernel | Each VM has its own OS |
| Lightweight | Heavy |
| Start in seconds | Takes minutes |
| Less resource usage | High CPU & RAM usage |
| Ideal for microservices | Ideal for full OS isolation |

Containers are more efficient because they do not require a full  OS.

---

## Docker Architecture

Docker follows a client-server architecture:

- **Docker Client** → CLI (docker commands)
- **Docker Daemon (dockerd)** → Runs containers containerd
- **Docker Images** → Blueprint/template for containers
- **Docker Containers** → Running instances of images
- **Docker Registry** → Stores images (Docker Hub)

### In Simple Terms

When I run:

docker run nginx

1. Docker client sends request to daemon
2. Daemon checks if image exists locally
3. If not, it pulls from Docker Hub
4. Creates and starts container from image

---

# 🛠 Task 2 – Install Docker

## Install on (Ubuntu)
```bash
sudo apt update
sudo apt install -y docker.io
```
Check docker service
```bash
sudo systemctl status docker
```
Start docker service
```bash
sudo systemctl start docker
sudo systemctl enable docker
```
Verify Installation
```bash
docker --version
```
check docker ps
using following command
```bash
docker ps
```
if its not working then there is user permission issue
Add user to docker group
```bash
sudo usermod -aG docker $USER
```
refresh the docker group
```bash
newgrp docker
```
now run docker ps its working now

Test Docker
```bash
docker run hello-world
```
This command pulls the hello-world image and runs it in a container. If successful, I should see a message confirming that Docker is working correctly.

The output explained:
- Docker client contacted daemon
- Pulled image from Docker Hub
- Created container
- Ran it successfully

![Hello world](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/93a80ee80acc3602122f4f7ca116a0aff43c1ca4/2026/day-29/images/task%202.jpg)
---
# 🐳 Task 3 – Run Real Containers
## Run Nginx Container

```bash
docker run -d -p 81:80 --name nginx nginx
```
![nginx](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/93a80ee80acc3602122f4f7ca116a0aff43c1ca4/2026/day-29/images/task%203.jpg)

This command does the following:
- `-d`: Run container in detached mode (in the background)
- `-p 81:80`: Map host port 81 to container port 80
- `--name nginx`: Name the container “nginx”
- `nginx`: Use the nginx image from Docker Hub
Now I can access the Nginx welcome page by navigating to `http://localhost:81` in my browser.

![nginx1](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/93a80ee80acc3602122f4f7ca116a0aff43c1ca4/2026/day-29/images/task%203.1.jpg)

## Run Ubuntu Container
```bash
docker run -it ubuntu 
```
This command runs an interactive terminal (`-it`) in an Ubuntu container. I can now run commands inside the container, like `ls`, `pwd`, or `apt update`.
To exit the container, I can type `exit`.

![ubuntu](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/93a80ee80acc3602122f4f7ca116a0aff43c1ca4/2026/day-29/images/task%203.2.jpg)
---
## List Running Containers
```bash
docker ps
```
This command lists all currently running containers, showing their IDs, names, status, and ports.
## List All Containers
```bash
docker ps -a
```
This command lists all containers, including those that are stopped or exited.

![ps](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/93a80ee80acc3602122f4f7ca116a0aff43c1ca4/2026/day-29/images/task%203.3.jpg)

## Stop a Container
```bash
docker stop nginx
```
This command stops the running container named “nginx”.
## Remove a Container
```bash
docker rm nginx
```
This command removes the stopped container named “nginx” from the system.
## stop and remove Container
```bash
docker stop c7b849dbb199 && docker rm c7b849dbb199
or
docker rm -f c7b849dbb199
or 
docker stop nginx && docker rm nginx
```
This command stops and removes the container with ID `c7b849dbb199` in one step.
## Remove All Containers
```bash
docker rm $(docker ps -a -q)
```
This command removes all containers by first listing all container IDs and then passing them to `docker rm`.

---
# 🔍 Task 4 – Exploration
## Detached Mode
Running a container in detached mode allows it to run in the background without tying up the terminal. This is useful for services that need to run continuously, like web servers or databases.
```bash
docker run -d nginx
```
Difference:
- Runs in background
- Terminal is free

## Custom Name
```bash
docker run -d --name webserver nginx
```
## Port Mapping
```bash
docker run -d -p 3000:80 nginx
```
Maps host port 3000 → container port 80

## View Logs
```bash
docker logs webserver
```
View output of container logs


## Execute Command Inside Running Container
```bash
docker exec -it webserver bash
```
This command opens an interactive terminal inside the running container named “webserver”, allowing me to run commands directly within the container’s environment.

# 🎯 Key Learnings
- Docker is a containerization platform that allows developers to package applications with their dependencies.
- Containers are lightweight and share the host OS kernel, making them more efficient than virtual machines.
- Docker architecture consists of a client, daemon, images, containers, and registry.
- I can run, stop, and manage containers using Docker CLI commands.
- Docker Hub is a public registry for sharing container images.
- Running containers in detached mode allows them to run in the background, freeing up the terminal for other tasks.
- Port mapping allows me to access containerized applications from the host machine.
- I can view logs and execute commands inside running containers for debugging and management purposes.
---

# 🚀 Why This Matters for DevOps
Docker is a fundamental tool in modern DevOps practices. It enables:
- Consistent environments across development, testing, and production
- Faster application deployment and scaling
- Simplified dependency management
- Easier collaboration between development and operations teams
By mastering Docker, I can streamline the software delivery process and improve the reliability of applications in production.
