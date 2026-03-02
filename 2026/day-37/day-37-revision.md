# Day 37 – Docker Revision & Self-Assessment

---

# ✅ Self-Assessment Checklist

✔ Run containers (interactive & detached) – CAN DO  
✔ Manage containers & images – CAN DO  
✔ Explain image layers & caching – CAN DO  
✔ Write Dockerfile from scratch – CAN DO  
✔ Explain CMD vs ENTRYPOINT – CAN DO  
✔ Build & tag custom image – CAN DO  
✔ Use named volumes – CAN DO  
✔ Use bind mounts – CAN DO  
✔ Create custom networks – CAN DO  
✔ Write multi-container compose file – CAN DO  
✔ Use .env with Compose – CAN DO  
✔ Write multi-stage Dockerfile – CAN DO  
✔ Push image to Docker Hub – CAN DO  
✔ Use healthchecks & depends_on – CAN DO  

---

# ⚡ Quick-Fire Answers

## 1. Difference between image and container?

Image = blueprint/template.  
Container = running instance of an image.

---

## 2. What happens to container data when removed?

Data inside container’s writable layer is deleted unless stored in a volume.

---

## 3. How do containers on same custom network communicate?

Using container name as hostname via Docker’s internal DNS.

---

## 4. docker compose down -v vs docker compose down?

down → removes containers & network  
down -v → also removes volumes (deletes persistent data)

---

## 5. Why multi-stage builds?

- Smaller image size  
- No build tools in final image  
- Faster deployments  
- Reduced attack surface  

---

## 6. COPY vs ADD?

COPY → simple file copy  
ADD → copy + extract tar + support URL (rarely needed)

Best practice: use COPY unless ADD is required.

---

## 7. What does -p 8080:80 mean?

Maps host port 8080 → container port 80.

---

## 8. How to check Docker disk usage?

docker system df

---

# 🔁 Weak Areas Revisited

## 1. Healthchecks & depends_on

Re-tested DB startup delay and confirmed app waits until service_healthy.

## 2. Multi-stage optimization

Compared image size before and after Alpine base + multi-stage.

Confirmed major size reduction.

---

# 🧠 Key Revision Takeaways

- Containers are ephemeral by design.
- Volumes ensure persistence.
- Custom networks enable service discovery.
- Multi-stage builds are essential for production.
- Proper tagging prevents deployment issues.
- Compose simplifies multi-container orchestration.
- Security best practices (non-root user, minimal base image) are critical.

---

# 🚀 Conclusion

Days 29–36 transitioned from:

Running containers →  
Building custom images →  
Orchestrating full application stacks →  
Optimizing & shipping production-ready images.

Docker fundamentals are now consolidated and job-ready.