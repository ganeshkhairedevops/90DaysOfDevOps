# Day 34 – Docker Compose: Real-World Multi-Container Apps

Today I built a production-style 3-service stack using Docker Compose:

- Flask Web App (Python)
- MySQL Database
- Redis Cache

---

## Stack Architecture

Web → MySQL  
Web → Redis  

All services connected through a custom bridge network.

---

# Task 1 – 3-Service App Stack

Services:
- web (Flask-app)
- db (MySQL)
- redis (Redis-cache)

The web app connects to:
- MySQL via service name `db`
- Redis via service name `redis`

![image](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/c549228dab341baccbf4ebebfb7397102d2f1ae8/2026/day-34/images/task%201.jpg)

logs

![logs](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/c549228dab341baccbf4ebebfb7397102d2f1ae8/2026/day-34/images/task%202.jpg)

application

![application](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/c549228dab341baccbf4ebebfb7397102d2f1ae8/2026/day-34/images/final.jpg)

---

# Task 2 – depends_on & Healthchecks

Added:
```
depends_on:
  db:
    condition: service_healthy
```
MySQL healthcheck:
```
healthcheck:
  test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
  interval: 10s
  timeout: 5s
  retries: 5
```
Result:
The web container waits until MySQL is actually ready before starting.

Without service_healthy, the app crashes because MySQL isn't ready yet.

---

# Task 3 – Restart Policies

Tested:
```
restart: always  
```
```
restart: on-failure  
```
restart: always
- Restarts no matter what
- Even after docker stop
- Best for databases and critical services

restart: on-failure
- Only restarts if exit code != 0
- Does NOT restart if container is manually stopped
- Good for batch jobs or workers

![task](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/c549228dab341baccbf4ebebfb7397102d2f1ae8/2026/day-34/images/task%203.jpg)


---

# Task 4 – Custom Dockerfile

Used:
```
build: ./app
```
After changing app code:

Rebuild and restarted in one command.
```
docker compose up --build -d
```

![rebuild](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/c549228dab341baccbf4ebebfb7397102d2f1ae8/2026/day-34/images/task%204.JPG)

Rebuild after changes

![rebuild1](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/c549228dab341baccbf4ebebfb7397102d2f1ae8/2026/day-34/images/task%204.1.JPG)

---

# Task 5 – Named Networks & Volumes

Created:

- Custom network: app-network
- Named volume: db_data

Benefits:
- Persistent database storage
- Explicit networking control
- Cleaner architecture

Added labels for organization.

---

# Task 6 – Scaling (Bonus)

Command:
```
docker compose up --scale web=3
```
Result:
Scaling fails if using:

ports:
  - "5000:5000"

Error:
Port conflict — multiple containers cannot bind to same host port.

Why Scaling Breaks with Port Mapping:

Only one container can bind to host port 5000.
Scaling requires a load balancer or reverse proxy.

Production Fix:
- Nginx reverse proxy
- Traefik
- Remove direct port binding from scaled service

---

# Commands Used

Start:
```
docker compose up -d
```
Rebuild:
```
docker compose up --build
```
Scale:
```
docker compose up --scale web=3
```
Stop:
```
docker compose down
```
---

# What I Learned

- depends_on alone is NOT enough
- Healthchecks are critical
- Restart policies matter in production
- Named volumes are required for databases
- Scaling needs load balancing
- Compose can simulate real-world architecture


## Key Features Implemented

✔ Custom Dockerfile for web app  
✔ Named volume for MySQL persistence  
✔ Explicit custom network  
✔ Healthcheck for MySQL  
✔ depends_on with service_healthy  
✔ Restart policies (always & on-failure)  
✔ Service labels  
✔ Scaling experiment  

---

## Healthcheck

Used mysqladmin ping to verify DB readiness before starting web service.

Ensures proper startup order in production-like environment.

---

## Restart Policies

restart: always  
Used for database to ensure high availability.

restart: on-failure  
Used for web app to restart only if crashes.

---

This setup closely simulates real-world microservice architecture.