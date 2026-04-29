# Day 74 -- Node Exporter, cAdvisor, and Grafana Dashboards

---

## Challenge Tasks

### Task 1: Add Node Exporter for Host Metrics
Node Exporter exposes Linux system metrics (CPU, memory, disk, filesystem, network) in Prometheus format.

Update your `docker-compose.yml` from Day 73 -- add the Node Exporter service:
```yaml
  node-exporter:
    image: prom/node-exporter:latest
    container_name: node-exporter
    ports:
      - "9100:9100"
    volumes:
      - /proc:/host/proc:ro
      - /sys:/host/sys:ro
      - /:/rootfs:ro
    command:
      - '--path.procfs=/host/proc'
      - '--path.sysfs=/host/sys'
      - '--path.rootfs=/rootfs'
      - '--collector.filesystem.mount-points-exclude=^/(sys|proc|dev|host|etc)($$|/)'
    restart: unless-stopped
```

**Why these volume mounts?**
- `/proc` -- kernel and process information (CPU stats, memory info)
- `/sys` -- hardware and driver details
- `/` -- filesystem usage (disk space)

All mounted read-only (`ro`) -- Node Exporter only reads, never modifies.

Add it as a scrape target in `prometheus.yml`:
```yaml
scrape_configs:
  - job_name: "prometheus"
    static_configs:
      - targets: ["localhost:9090"]

  - job_name: "node-exporter"
    static_configs:
      - targets: ["node-exporter:9100"]
```

Restart the stack:
```bash
docker compose up -d
```

Verify Node Exporter is healthy:
```bash
curl http://localhost:9100/metrics | head -20
```
![task 1](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/6e0193b2ef8e118eba39dc847867e7fed27d89d7/2026/day-74/images/task%201.JPG)

```bash
curl -s http://localhost:9100/metrics | grep -q node_exporter_build_info && echo OK
```

![task 1.1](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/6e0193b2ef8e118eba39dc847867e7fed27d89d7/2026/day-74/images/task%201.1.JPG)

Check Prometheus Targets page -- `node-exporter` should show as `UP`.

![task1.2](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/6e0193b2ef8e118eba39dc847867e7fed27d89d7/2026/day-74/images/task%201.2.JPG)

Run these queries in Prometheus to see host metrics:

## CPU: percentage of time spent idle (per core)
**node_cpu_seconds_total{mode="idle"}**

![task1.3](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/6e0193b2ef8e118eba39dc847867e7fed27d89d7/2026/day-74/images/task%201.3.JPG)

## Memory: total vs available
**node_memory_MemTotal_bytes**
![task1.4](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/6e0193b2ef8e118eba39dc847867e7fed27d89d7/2026/day-74/images/task%201.4.JPG)

**node_memory_MemAvailable_bytes**

![task1.5](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/6e0193b2ef8e118eba39dc847867e7fed27d89d7/2026/day-74/images/task%201.5.JPG)

## Memory usage percentage
**(1 - node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes) * 100**


![task1.6](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/6e0193b2ef8e118eba39dc847867e7fed27d89d7/2026/day-74/images/task%201.6.JPG)

## Disk: filesystem usage percentage
**(1 - node_filesystem_avail_bytes / node_filesystem_size_bytes) * 100**


![task1.7](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/6e0193b2ef8e118eba39dc847867e7fed27d89d7/2026/day-74/images/task%201.7.JPG)

## Network: bytes received per second
**rate(node_network_receive_bytes_total[5m])**

`Network receive rate on eth0 is approximately 46 bytes per second`

![task1.8](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/6e0193b2ef8e118eba39dc847867e7fed27d89d7/2026/day-74/images/task%201.8.JPG)
---

### Task 2: Add cAdvisor for Container Metrics
cAdvisor (Container Advisor) monitors resource usage and performance of running Docker containers.

Add it to your `docker-compose.yml`:
```yaml
  cadvisor:
    image: gcr.io/cadvisor/cadvisor:latest
    container_name: cadvisor
    ports:
      - "8080:8080"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - /sys:/sys:ro
      - /var/lib/docker/:/var/lib/docker:ro
    restart: unless-stopped
```

**Why these volume mounts?**
- Docker socket (`docker.sock`) -- lets cAdvisor discover and query running containers
- `/sys` -- kernel-level container stats (cgroups)
- `/var/lib/docker/` -- container filesystem information

Add cAdvisor as a Prometheus scrape target:
```yaml
  - job_name: "cadvisor"
    static_configs:
      - targets: ["cadvisor:8080"]
```

Restart and verify:
```bash
docker compose up -d
```

Open `http://localhost:8080` to see the cAdvisor web UI. Click on Docker Containers to see per-container stats.

![task2](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/6e0193b2ef8e118eba39dc847867e7fed27d89d7/2026/day-74/images/task%202.JPG)
![task2.t](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/6e0193b2ef8e118eba39dc847867e7fed27d89d7/2026/day-74/images/task%202.t1.JPG)


Run these queries in Prometheus:

## CPU usage per container (in seconds)
**rate(container_cpu_usage_seconds_total{id!="/", id=~".*docker.*"}[5m])**

![task2.1](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/6e0193b2ef8e118eba39dc847867e7fed27d89d7/2026/day-74/images/task%202.1.JPG)

## Memory usage per container
**container_memory_usage_bytes{id!="/", id=~".*docker.*"}**

![task2.2](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/6e0193b2ef8e118eba39dc847867e7fed27d89d7/2026/day-74/images/task%202.2.JPG)

## Network received bytes per container
**rate(container_network_receive_bytes_total{id=~".*docker.*scope"}[5m])**

![task2.3](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/6e0193b2ef8e118eba39dc847867e7fed27d89d7/2026/day-74/images/task%202.3.JPG)

## Which container is using the most memory?
**topk(3, container_memory_usage_bytes{id=~".*docker.*scope"}) /1024 /1024**

![task2.4](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/6e0193b2ef8e118eba39dc847867e7fed27d89d7/2026/day-74/images/task%202.4.JPG)


The {name!=""} filter removes aggregated/system-level entries and shows only named containers.

**Document:** What is the difference between Node Exporter and cAdvisor? When would you use each?

- `Node Exporter` is used to monitor **host/system-level metrics** like CPU, memory, disk, and network of the entire machine.

- `cAdvisor` is used to monitor **container-level metrics** like CPU and memory usage per container.

- Use `Node Exporter` for **server monitoring** and `cAdvisor` for **container monitoring**.



### Task 3: Set Up Grafana
Grafana is the visualization layer. It connects to Prometheus (and later Loki) and lets you build dashboards, set alerts, and share views with your team.

Add Grafana to your `docker-compose.yml`:
```yaml
  grafana:
    image: grafana/grafana-enterprise:latest
    container_name: grafana
    ports:
      - "3000:3000"
    volumes:
      - grafana_data:/var/lib/grafana
    environment:
      - GF_SECURITY_ADMIN_USER=admin
      - GF_SECURITY_ADMIN_PASSWORD=admin123
    restart: unless-stopped
```

Add the volume at the bottom of your compose file:
```yaml
volumes:
  prometheus_data:
  grafana_data:
```

Restart:
```bash
docker compose up -d
```

Open `http://localhost:3000`. Log in with `admin` / `admin123`.

**Add Prometheus as a datasource:**
1. Go to Connections > Data Sources > Add data source
2. Select Prometheus
3. Set URL to `http://prometheus:9090` (use the container name, not localhost -- they are on the same Docker network)
4. Click Save & Test -- you should see "Successfully queried the Prometheus API"

![task3](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/6e0193b2ef8e118eba39dc847867e7fed27d89d7/2026/day-74/images/task%203.JPG)
---

### Task 4: Build Your First Dashboard
Create a dashboard that shows the health of your system at a glance.

1. Go to Dashboards > New Dashboard > Add Visualization
2. Select Prometheus as the datasource

**Panel 1 -- CPU Usage (Gauge):**
```promql
100 - (avg(rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)
```
- Visualization: Gauge
- Title: "CPU Usage %"
- Set thresholds: green < 60, yellow < 80, red >= 80

**Panel 2 -- Memory Usage (Gauge):**
```promql
(1 - node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes) * 100
```
- Visualization: Gauge
- Title: "Memory Usage %"

**Panel 3 -- Container CPU Usage (Time Series):**
```promql
rate(container_cpu_usage_seconds_total{id!="/", id=~".*docker.*"}[5m])
```
- Visualization: Time series
- Title: "Container CPU Usage"
- Legend: `{{name}}`

**Panel 4 -- Container Memory Usage (Bar Chart):**
```promql
container_memory_usage_bytes{id!="/", id=~".*docker.*"}
```
- Visualization: Bar chart
- Title: "Container Memory (MB)"
- Legend: `{{name}}`

**Panel 5 -- Disk Usage (Stat):**
```promql
(1 - node_filesystem_avail_bytes{mountpoint="/"} / node_filesystem_size_bytes{mountpoint="/"}) * 100
```
- Visualization: Stat
- Title: "Disk Usage %"

Save the dashboard as "DevOps Observability Overview".


![task4](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/6e0193b2ef8e118eba39dc847867e7fed27d89d7/2026/day-74/images/task%204.JPG)
---

### Task 5: Auto-Provision Datasources with YAML
In production, you do not click through the UI to add datasources. You provision them with configuration files so the setup is repeatable.

Create the provisioning directory structure:
```bash
mkdir -p grafana/provisioning/datasources
mkdir -p grafana/provisioning/dashboards
```

Create `grafana/provisioning/datasources/datasources.yml`:
```yaml
apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus:9090
    isDefault: true
    editable: false
```

Update the Grafana service in `docker-compose.yml` to mount the provisioning directory:
```yaml
  grafana:
    image: grafana/grafana-enterprise:latest
    container_name: grafana
    ports:
      - "3000:3000"
    volumes:
      - grafana_data:/var/lib/grafana
      - ./grafana/provisioning:/etc/grafana/provisioning
    environment:
      - GF_SECURITY_ADMIN_USER=admin
      - GF_SECURITY_ADMIN_PASSWORD=admin123
    restart: unless-stopped
```

Restart Grafana:
```bash
docker compose up -d grafana
```

Check Connections > Data Sources -- Prometheus should already be there without any manual setup.

![task5](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/6e0193b2ef8e118eba39dc847867e7fed27d89d7/2026/day-74/images/task%205.JPG)

**Document:** Why is provisioning datasources via YAML better than configuring them manually through the UI?

Provisioning datasources via YAML allows for:
- **Version control**: You can track changes to your datasource configuration in Git.
- **Automation**: Easily automate Grafana setup in CI/CD pipelines or infrastructure as code.
- **Consistency**: Ensures all environments (dev, staging, prod) have the same datasource configuration without manual errors.


---

### Task 6: Import a Community Dashboard
The Grafana community maintains thousands of pre-built dashboards. Import one for Node Exporter:

1. Go to Dashboards > New > Import
2. Enter dashboard ID: **1860** (Node Exporter Full)
3. Select your Prometheus datasource
4. Click Import

Explore the imported dashboard. It has dozens of panels covering CPU, memory, disk, network, and more -- all built on the same Node Exporter metrics you queried manually.


![task6](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/6e0193b2ef8e118eba39dc847867e7fed27d89d7/2026/day-74/images/task%206.JPG)

**Try another one:** Import dashboard ID **193** (Docker monitoring via cAdvisor). Select Prometheus as the datasource and explore container-level stats.

**Your full `docker-compose.yml` should now have these services:**
- `prometheus`
- `node-exporter`
- `cadvisor`
- `grafana`
- `notes-app` (from Day 73)

Verify all are running:
```bash
docker compose ps
```
![task6.1](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/6e0193b2ef8e118eba39dc847867e7fed27d89d7/2026/day-74/images/task%206.1.JPG)
---


### Difference between Node Exporter and cAdvisor (when to use which)
- `Node Exporter` is used to monitor **host/system-level metrics** like CPU, memory, disk, and network of the entire machine.
- `cAdvisor` is used to monitor **container-level metrics** like CPU and memory usage per container.



`
---

### How datasource provisioning works via YAML

The `datasources.yml` file defines the datasources Grafana should automatically set up on startup. The `apiVersion: 1` is required.
The `datasources` section lists each datasource with its configuration:
- `name`: The name that will appear in Grafana (e.g., "Prometheus")
- `type`: The type of datasource (e.g., "prometheus")
- `access`: How Grafana should access the datasource (e.g., "proxy" means Grafana will proxy requests to Prometheus)
- `url`: The URL to access Prometheus from Grafana's perspective (use the Docker service name, not localhost)
- `isDefault`: Whether this datasource should be the default for new panels
- `editable`: Whether users can edit this datasource in the Grafana UI (set to false for production)
When Grafana starts, it reads this YAML file and automatically creates the Prometheus datasource with the specified configuration. This eliminates the need to manually add the datasource through the UI, making it easier to automate and version control your Grafana setup.
