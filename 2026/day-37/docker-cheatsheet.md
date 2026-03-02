# 🐳 Docker Cheat Sheet (Days 29–36)

A quick reference for daily DevOps work.

---

## 🐳 Container Commands

```bash
docker run image                  # Run container
docker run -it image              # Interactive mode
docker run -d image               # Detached mode
docker ps                         # List running containers
docker ps -a                      # List all containers
docker stop container             # Stop container
docker rm container               # Remove container
docker exec -it <container id> sh # Enter running container
docker logs container             # View container logs
docker restart <container>        # Restart a container
docker logs -f container          # Follow logs live
docker rm -f $(docker ps -aq)     #delete all Docker containers (both running and stopped)
docker stop <container id> && docker rm <container id> # stop and remove docker container

```

---

## 📦 Image Commands

```bash
docker build -t name:tag .       # Build image
docker images                    # List images
docker rmi image                 # Remove image
docker pull image                # Pull image
docker push image                # Push image
docker tag src dest              # Tag image
```

---

## 💾 Volume Commands

```bash
docker volume ls                 # List volumes
docker volume create name        # Create volume
docker volume inspect name       # Inspect volume
docker volume rm name            # Remove volume
```

---

## 🌐 Network Commands

```bash
docker network ls                # List networks
docker network create name       # Create network
docker network inspect name      # Inspect network
docker network connect net c     # Connect container to network
```

---

## 🧩 Docker Compose Commands

```bash
docker compose up -d             # Start services (detached)
docker compose up --build        # Rebuild & start
docker compose down              # Stop & remove services
docker compose down -v           # Remove services + volumes
docker compose ps                # List services
docker compose logs -f           # View logs
docker compose stop              # Stop without removing
```

---

## 🧹 Cleanup Commands

```bash
docker system df                 # Check disk usage
docker container prune           # Remove stopped containers
docker image prune               # Remove unused images
docker volume prune              # Remove unused volumes
docker system prune              # Remove unused everything
```

---

## 🏗 Dockerfile Instructions

```dockerfile
FROM        # Base image
RUN         # Execute command during build
COPY        # Copy files into image
WORKDIR     # Set working directory
EXPOSE      # Document port
CMD         # Default runtime command
ENTRYPOINT  # Enforced command
USER        # Set non-root user
ENV         # Set environment variable
```
