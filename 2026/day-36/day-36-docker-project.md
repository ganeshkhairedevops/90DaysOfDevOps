# Day 36 – Docker Project: Dockerize a Full Application

## 🚀 Project Overview

For Day 36, I Dockerized a full Flask + PostgreSQL application end-to-end.

This project simulates a real-world backend service connected to a database, fully containerized using Docker and Docker Compose.

---

## 🧠 Why I Chose This App

I chose a Flask + PostgreSQL stack because:

- It represents a common production backend setup
- Demonstrates service-to-service communication
- Requires environment variable configuration
- Needs persistent database storage
- Is interview-relevant and practical

This project covers real DevOps workflow: build → compose → persist → healthcheck → ship.

---

# 🏗 Architecture
```
Flask App (Web Service)
        ↓
PostgreSQL Database
        ↓
Named Volume for Persistence
```
All services connected via a custom Docker network.

---

# 🐳 Dockerfile (With Explanation)

Located in: `app/Dockerfile`

```dockerfile
# Stage 1 - Builder
FROM python:3.10-slim AS builder

WORKDIR /app
COPY requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt

# Stage 2 - Runtime
FROM python:3.10-slim

WORKDIR /app

# Create non-root user
RUN useradd -m appuser

# Copy installed packages from builder
COPY --from=builder /root/.local /root/.local

# Copy app source
COPY . .

ENV PATH=/root/.local/bin:$PATH

USER appuser

EXPOSE 5000

CMD ["python", "app.py"]
```

![application deploy](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/3fdf0c7141d0a02f5c92bbdbd7d7569700445e70/2026/day-36/images/task%201.jpg)

![deploy](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/3fdf0c7141d0a02f5c92bbdbd7d7569700445e70/2026/day-36/images/task%201.1.jpg)



### Explanation:
- **Multi-stage Build**: Separates dependency installation from runtime, resulting in a smaller final image.
- **Non-root User**: Enhances security by running the app as a non-root user.
- **Environment Variables**: The app will read database connection info from environment variables set in `docker-compose.yml`.
- **No Cache**: Ensures a clean install of dependencies without caching.
- **Port Exposure**: Exposes port 5000 for the Flask app.
---