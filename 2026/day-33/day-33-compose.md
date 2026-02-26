# Day 33 – Docker Compose: Multi-Container Basics

Today I learned how to run multi-container applications using Docker Compose.

Instead of manually creating networks, volumes, and containers, Docker Compose allows defining

---
# Task 1 – Install & Verify
## Check Version
```bash
docker compose version
```
![docker compose]()

If Docker compose not install
install doceker compose.
## Install Docker Compose
```bash
sudo apt-get update
sudo apt-get install docker-compose-plugin
```
## Verify Installation
```bash
docker compose version
```
---
# Task 2 – First Compose File
## Create a Docker Compose File
```yaml
version: '3.9'

services:
  nginx:
    image: nginx
    ports:
      - "8080:80"
```
## Run the Application
```bash
docker compose up -d
```
![docker]()

## Verify the Application
```bash
curl http://localhost:8080
```
![nginx]()
## Stop the Application
```bash
docker compose down
```
![docker compose down]()

---

# Task 3 – Two-Container Setup (WordPress + MySQL)
## Create a Docker Compose File
```yaml
version: '3.9'
services:
  db:
    image: mysql:8.0
    container_name: wordpress-db
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}
      MYSQL_DATABASE: ${MYSQL_DATABASE}
      MYSQL_USER: ${MYSQL_USER}
      MYSQL_PASSWORD: ${MYSQL_PASSWORD}
    volumes:
      - db_data:/var/lib/mysql

  wordpress:
    image: wordpress:latest
    container_name: wordpress-app
    restart: always
    ports:
      - "8080:80"
    environment:
      WORDPRESS_DB_HOST: db
      WORDPRESS_DB_USER: ${MYSQL_USER}
      WORDPRESS_DB_PASSWORD: ${MYSQL_PASSWORD}
      WORDPRESS_DB_NAME: ${MYSQL_DATABASE}
    depends_on:
      - db

volumes:
  db_data:
```

## Create Environment Variables
.env file

```bash
export MYSQL_ROOT_PASSWORD=your_password_here
export MYSQL_DATABASE=wordpress
export MYSQL_USER=wpuser
export MYSQL_PASSWORD=your_password_here
```
## Run the Application
```bash
docker compose up -d
```
![task3]()

## check same network 
```bash
docker network ls
docker network inspect <network_name>
```
![task3.1]()

## Verify the Application
Open a web browser and navigate to `http://localhost:8080`. You should see the WordPress setup page.

![task3.2]()

![task3.3]()

## Stop the Application
```bash
docker compose down
```
---
after start application
data still remaining.
```bash
docker compose up -d
```
![task3.4]()

---

# 📘 Task 4 – Compose Commands

## Start Detached
```bash
docker compose up -d
```
## View Running Services
```bash
docker compose ps
```
## View All Logs
```bash
docker compose logs -f
```
## View Logs for Specific Service
```bash
docker compose logs -f db
```
## Stop Without Removing
```bash
docker compose stop
```
## Remove Everything
```bash
docker compose down
```
## Rebuild Images
```bash
docker compose up --build
```
## Scale Services
```bash
docker compose up -d --scale wordpress=3
```
## View Resource Usage
```bash
docker compose top
```
## Execute Command in Running Container
```bash
docker compose exec wordpress bash
```
## View Container Stats
```bash
docker compose stats
```
## Remove Volumes
```bash
docker compose down -v
```
## Remove Images
```bash
docker compose down --rmi all
```
## Remove Networks
```bash
docker compose down --remove-orphans
```
## View Configuration
```bash
docker compose config
```
## View Events
```bash
docker compose events
```
---

# Task 5 – Environment Variables

Used environment variables in two ways:

1. Directly in docker-compose.yml
2. Using .env file

Verified variables were loaded correctly by inspecting container:

docker inspect wordpress-db

Compose automatically reads variables from .env file in the same directory.

---

# 🧠 Key Learnings
- Docker Compose simplifies multi-container application management.
- Services, networks, and volumes can be defined in a single YAML file.
- Environment variables can be used for configuration.
- Compose commands allow for easy control over the application lifecycle.
- Volumes ensure data persistence across container restarts.
- Compose automatically creates a default network for services to communicate.
- Using `depends_on` ensures service startup order, but does not guarantee readiness.
- Scaling services is easy with Docker Compose.
