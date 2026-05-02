# Day 75 -- Log Management with Loki and Promtail
Today, we explored log management using Loki and Promtail. Loki is a log aggregation system designed for storing and querying logs efficiently, while Promtail is an agent that collects logs and sends them to Loki.
---

## Challenge Tasks

### Task 1: Understand the Logging Pipeline
Before writing any config, understand how the pieces fit together:

```
[Docker Containers]
       |
       | (write JSON logs to /var/lib/docker/containers/)
       v
  [Promtail]
       |
       | (reads log files, adds labels, pushes to Loki)
       v
    [Loki]
       |
       | (stores logs, indexes by labels)
       v
   [Grafana]
       |
       | (queries Loki with LogQL, displays logs)
       v
   [You]
```

Key differences from the ELK stack:
- Loki does **not** index the full text of logs -- it only indexes labels (like container name, job, filename)
- This makes Loki much cheaper to run and simpler to operate
- Think of it as "Prometheus, but for logs" -- same label-based approach

**Document:** Why does Loki only index labels instead of full text? What is the trade-off?

- Loki indexes only labels to keep storage and costs low.
- The trade-off is that you cannot search for arbitrary text within logs; you must filter by labels first.


---
### Task 2: Add Loki to the Stack
Create the Loki configuration file.

```bash
mkdir -p loki
```

Create `loki/loki-config.yml`:
```yaml
auth_enabled: false

server:
  http_listen_port: 3100

common:
  ring:
    instance_addr: 127.0.0.1
    kvstore:
      store: inmemory
  replication_factor: 1
  path_prefix: /loki

schema_config:
  configs:
    - from: 2020-10-24
      store: tsdb
      object_store: filesystem
      schema: v13
      index:
        prefix: index_
        period: 24h

storage_config:
  filesystem:
    directory: /loki/chunks
```

**What this config does:**
- `auth_enabled: false` -- single-tenant mode, no authentication needed
- `store: tsdb` -- uses Loki's time-series database for indexing
- `object_store: filesystem` -- stores log chunks on local disk
- `replication_factor: 1` -- single instance, no replication (fine for learning)

Add Loki to your `docker-compose.yml`:
```yaml
  loki:
    image: grafana/loki:latest
    container_name: loki
    ports:
      - "3100:3100"
    volumes:
      - ./loki/loki-config.yml:/etc/loki/loki-config.yml
      - loki_data:/loki
    command: -config.file=/etc/loki/loki-config.yml
    restart: unless-stopped
```

Add `loki_data` to your volumes section:
```yaml
volumes:
  prometheus_data:
  grafana_data:
  loki_data:
```

Start Loki:
```bash
docker compose up -d loki
```

Verify Loki is running:
```bash
curl http://localhost:3100/ready
```

You should see `ready`.

![task2](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/f39dd6b8e46379d4b3274b50a47ad9e2c46c40a3/2026/day-75/images/task%202.jpg)

---
### Task 3: Add Promtail to Collect Container Logs
Promtail is the log collection agent. It reads Docker container log files from the host and pushes them to Loki.

```bash
mkdir -p promtail
```

Create `promtail/promtail-config.yml`:
```yaml
server:
  http_listen_port: 9080
  grpc_listen_port: 0

positions:
  filename: /tmp/positions.yaml

clients:
  - url: http://loki:3100/loki/api/v1/push

scrape_configs:
  - job_name: docker
    static_configs:
      - targets:
          - localhost
        labels:
          job: docker
          __path__: /var/lib/docker/containers/*/*-json.log
    pipeline_stages:
      - docker: {}
```

**What this config does:**
- `positions` -- tracks which log lines have already been shipped (like a bookmark)
- `clients` -- where to send logs (Loki endpoint)
- `__path__` -- the glob pattern to find Docker JSON log files on the host
- `pipeline_stages: docker: {}` -- parses the Docker JSON log format and extracts timestamp, stream (stdout/stderr), and the log message

Add Promtail to your `docker-compose.yml`:
```yaml
  promtail:
    image: grafana/promtail:latest
    container_name: promtail
    volumes:
      - ./promtail/promtail-config.yml:/etc/promtail/promtail-config.yml
      - /var/lib/docker/containers:/var/lib/docker/containers:ro
      - /var/run/docker.sock:/var/run/docker.sock
    command: -config.file=/etc/promtail/promtail-config.yml
    restart: unless-stopped
```

**Why these volume mounts?**
- `/var/lib/docker/containers` -- where Docker stores container log files (read-only)
- `/var/run/docker.sock` -- lets Promtail discover container metadata (names, labels)

Restart the stack:
```bash
docker compose up -d
```

Generate some logs by hitting the notes app:
```bash
for i in $(seq 1 20); do curl -s http://localhost:8000 > /dev/null; done
```

---
### Task 4: Add Loki as a Grafana Datasource
You can add it manually through the UI or auto-provision it with YAML.

**Option A -- Provision via YAML (recommended):**

Update `grafana/provisioning/datasources/datasources.yml`:
```yaml
apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus:9090
    isDefault: true
    editable: false

  - name: Loki
    type: loki
    access: proxy
    url: http://loki:3100
    editable: false
```

Restart Grafana to pick up the new datasource:
```bash
docker compose restart grafana
```

**Option B -- Manual UI setup:**
1. Go to Connections > Data Sources > Add data source
2. Select Loki
3. URL: `http://loki:3100`
4. Save & Test

Either way, you should now have two datasources in Grafana: Prometheus and Loki.

![task 4](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/f39dd6b8e46379d4b3274b50a47ad9e2c46c40a3/2026/day-75/images/task%204.jpg)

---

### Task 5: Query Logs with LogQL
LogQL is Loki's query language -- similar to PromQL but for logs.

Go to Grafana > Explore (compass icon). Select Loki as the datasource.

1. **Stream selector** -- filter logs by labels:
```logql
{job="docker"}
```
This shows all Docker container logs.

![task5](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/f39dd6b8e46379d4b3274b50a47ad9e2c46c40a3/2026/day-75/images/task%205.jpg)

2. **Filter by container name:**
```logql
{container_name="prometheus"}
```
![task5.1](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/f39dd6b8e46379d4b3274b50a47ad9e2c46c40a3/2026/day-75/images/task%205.1.jpg)

3. **Keyword search** -- filter log lines by content:
```logql
{job="docker"} |= "error"
```
`|=` means "line contains". This finds all log lines with the word "error".

![task5.2](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/f39dd6b8e46379d4b3274b50a47ad9e2c46c40a3/2026/day-75/images/task%205.2.jpg)

4. **Negative filter:**
```logql
{job="docker"} != "health"
```
Excludes lines containing "health" (useful to filter out health check noise).

![task5.3](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/f39dd6b8e46379d4b3274b50a47ad9e2c46c40a3/2026/day-75/images/task%205.3.jpg)
![task5.4](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/f39dd6b8e46379d4b3274b50a47ad9e2c46c40a3/2026/day-75/images/task%205.4.jpg)

5. **Regex filter:**
```logql
{job="docker"} |~ "status=[45]\\d{2}"
```
Finds lines with HTTP 4xx or 5xx status codes.

![task5.5](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/f39dd6b8e46379d4b3274b50a47ad9e2c46c40a3/2026/day-75/images/task%205.5.jpg)

6. **Log metric queries** -- count log lines over time:
```logql
count_over_time({job="docker"}[5m])
```
![task5.6](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/f39dd6b8e46379d4b3274b50a47ad9e2c46c40a3/2026/day-75/images/task%205.6.jpg)

7. **Rate of logs per second:**
```logql
rate({job="docker"}[5m])
```
![task5.7](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/f39dd6b8e46379d4b3274b50a47ad9e2c46c40a3/2026/day-75/images/task%205.7.jpg)

8. **Top containers by log volume:**
```logql
topk(5, sum by (container_name) (rate({job="docker"}[5m])))
```
![task5.8](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/f39dd6b8e46379d4b3274b50a47ad9e2c46c40a3/2026/day-75/images/task5.7.jpg)

**Exercise:** Write a LogQL query that finds all error logs from the notes-app container in the last 1 hour. Then write another query that counts how many error lines per minute.

1. Find all error logs from notes-app in the last hour:
```logql
{container_name="notes-app"} |~ "(?i)error|404|exception"
```
2. Count how many error lines per minute:
```logql
count_over_time({container_name="notes-app"} |~ "(?i)error|404|exception"[1m])
```

---

### Task 6: Correlate Metrics and Logs in Grafana
The real power of observability is correlation -- seeing metrics and logs together.

1. **Add a logs panel to your dashboard:**
   - Open the dashboard you built on Day 74
   - Add a new panel
   - Select Loki as the datasource
   - Query: `{job="docker"}`
   - Visualization: Logs
   - Title: "Container Logs"

![task6](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/f39dd6b8e46379d4b3274b50a47ad9e2c46c40a3/2026/day-75/images/task%206.jpg)

2. **Use the Explore split view:**
   - Go to Explore
   - Click the split button (two panels side by side)
   - Left panel: Prometheus -- `rate(container_cpu_usage_seconds_total{name="notes-app"}[5m])`
   - Right panel: Loki -- `{container_name="notes-app"}`
   - Now you can see CPU spikes and the corresponding log output at the same time

![task6.1](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/f39dd6b8e46379d4b3274b50a47ad9e2c46c40a3/2026/day-75/images/task%206.1.jpg)

3. **Time sync:** Click on a spike in the metrics graph and both panels will zoom to that time range. This is how you debug in production -- you see a metric anomaly and immediately check the logs from that exact moment.

**Document:** How does having metrics and logs in the same tool (Grafana) help during incident response compared to checking separate systems?

Having metrics and logs in the same tool allows for seamless correlation. During an incident, you can quickly jump from a metric anomaly to the relevant logs without switching contexts or tools. This speeds up root cause analysis and reduces the time to resolution.
---

### Comparison: Loki vs ELK stack (when would you use each?)
- **Loki** is great for cost-effective log aggregation when you primarily need to filter by labels and don't require full-text search. It's simpler to operate and scales well for containerized environments.
- **ELK stack** (Elasticsearch, Logstash, Kibana) is more powerful for complex log analysis and full-text search, but it can be resource-intensive and harder to manage at scale. It's often used in traditional environments or when deep log analysis is required.
    

---
## Conclusion
Today we set up a complete log management pipeline using Loki and Promtail, and integrated it with Grafana for powerful querying and visualization. We learned how to write LogQL queries to filter and analyze logs, and how to correlate metrics and logs together for effective troubleshooting. This is a critical skill for any DevOps engineer, as logs often hold the key to understanding what happened during an incident.
---


