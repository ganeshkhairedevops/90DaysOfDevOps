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