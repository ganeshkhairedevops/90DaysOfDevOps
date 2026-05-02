# Day 76 -- OpenTelemetry and Alerting
Today, I want to talk about how OpenTelemetry can be used for alerting in software systems. OpenTelemetry is a powerful observability framework that provides a standard way to collect and export telemetry data such as traces, metrics,
and logs. This data can be invaluable for monitoring the health and performance of your applications, and it can also be used to set up alerts when certain conditions are met.

## What is OpenTelemetry?
OpenTelemetry is an open-source project that provides a set of APIs, libraries, and tools for collecting and exporting telemetry data from applications. It supports multiple programming languages and can be integrated with various backends for storing and analyzing the collected data.
## Alerting with OpenTelemetry
Alerting is the process of setting up notifications when certain conditions are met in your application. With OpenTelemetry, you can use the collected telemetry data to create alerts based on specific metrics or trace patterns. For example, you can set up an alert to trigger when the response time of a particular endpoint exceeds a certain threshold or when the error rate of a service increases significantly.
To set up alerting with OpenTelemetry, you can follow these steps:
1. **Collect Telemetry Data**: Use OpenTelemetry to instrument your application and collect the necessary telemetry data, such as metrics and traces.
2. **Export Data to a Backend**: Export the collected telemetry data to a backend that supports alerting, such as Prometheus, Grafana, or Datadog.
3. **Define Alerting Rules**: In your backend, define alerting rules based on the collected telemetry data. For example, you can create a rule that triggers an alert when the average response time exceeds a certain threshold.
4. **Set Up Notifications**: Configure your backend to send notifications when an alert is triggered. This can be done through various channels such as email, Slack, or PagerDuty.
## Benefits of Using OpenTelemetry for Alerting
Using OpenTelemetry for alerting has several benefits:

---

## Challenge Tasks

### Task 1: Understand OpenTelemetry
Research and write notes on:

1. **What is OpenTelemetry (OTEL)?**
   - A vendor-neutral, open-source framework for generating, collecting, and exporting telemetry data (metrics, logs, traces)
   - It is not a backend -- it collects and ships data to backends like Prometheus, Jaeger, Loki, Datadog

2. **What is the OTEL Collector?**
   - A standalone service that receives, processes, and exports telemetry
   - Three components in the pipeline:
     - **Receivers** -- accept data (OTLP, Prometheus, Jaeger formats)
     - **Processors** -- transform data (batching, filtering, sampling)
     - **Exporters** -- send data to backends (Prometheus, debug console, Jaeger)

3. **What is OTLP?**
   - OpenTelemetry Protocol -- the standard wire format for sending telemetry
   - Supports gRPC (port 4317) and HTTP (port 4318)

4. **What are distributed traces?**
   - A trace tracks a single request as it travels through multiple services
   - Each step in the trace is called a **span**
   - Spans have: trace ID, span ID, parent span ID, start time, duration, attributes
   - Example: User request -> API Gateway (span 1) -> Auth Service (span 2) -> Database (span 3)

---

### Task 2: Add the OpenTelemetry Collector
Create the collector configuration:

```bash
mkdir -p otel-collector
```

Create `otel-collector/otel-collector-config.yml`:
```yaml
receivers:
  otlp:
    protocols:
      grpc:
        endpoint: 0.0.0.0:4317
      http:
        endpoint: 0.0.0.0:4318

processors:
  batch:

exporters:
  prometheus:
    endpoint: "0.0.0.0:8889"
  debug:
    verbosity: detailed

service:
  pipelines:
    metrics:
      receivers: [otlp]
      processors: [batch]
      exporters: [prometheus]
    traces:
      receivers: [otlp]
      processors: [batch]
      exporters: [debug]
    logs:
      receivers: [otlp]
      processors: [batch]
      exporters: [debug]
```

**What this config does:**
- **Receivers:** Accepts OTLP data via gRPC (4317) and HTTP (4318)
- **Processors:** Batches data before exporting (reduces overhead)
- **Exporters:**
  - Metrics go to a Prometheus-compatible endpoint on port 8889 (Prometheus scrapes this)
  - Traces and logs go to debug output (console) -- in production you would send these to Jaeger or Tempo

Add the collector to your `docker-compose.yml`:
```yaml
  otel-collector:
    image: otel/opentelemetry-collector-contrib:latest
    container_name: otel-collector
    ports:
      - "4317:4317"   # OTLP gRPC
      - "4318:4318"   # OTLP HTTP
      - "8889:8889"   # Prometheus exporter
    volumes:
      - ./otel-collector/otel-collector-config.yml:/etc/otelcol-contrib/config.yaml
    restart: unless-stopped
```

Add the OTEL Collector as a Prometheus scrape target in `prometheus.yml`:
```yaml
  - job_name: "otel-collector"
    static_configs:
      - targets: ["otel-collector:8889"]
```

Restart everything:
```bash
docker compose up -d
```

Verify the collector is running:
```bash
docker logs otel-collector 2>&1 | tail -5
```
![task2](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/1fad84ce629f318f4d0c9f073ac8a5fecb270a54/2026/day-76/images/task%202.jpg)

Check Prometheus Targets -- you should now see `otel-collector` as UP.

![task2.1](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/1fad84ce629f318f4d0c9f073ac8a5fecb270a54/2026/day-76/images/taks%202.1.jpg)

---

### Task 3: Send Test Traces to the Collector
Send a sample OTLP trace using curl:

```bash
curl -X POST http://localhost:4318/v1/traces \
  -H "Content-Type: application/json" \
  -d '{
    "resourceSpans": [{
      "resource": {
        "attributes": [{
          "key": "service.name",
          "value": { "stringValue": "my-test-service" }
        }]
      },
      "scopeSpans": [{
        "spans": [{
          "traceId": "5b8efff798038103d269b633813fc60c",
          "spanId": "eee19b7ec3c1b174",
          "name": "test-span",
          "kind": 1,
          "startTimeUnixNano": "1544712660000000000",
          "endTimeUnixNano": "1544712661000000000",
          "attributes": [{
            "key": "http.method",
            "value": { "stringValue": "GET" }
          },
          {
            "key": "http.status_code",
            "value": { "intValue": "200" }
          }]
        }]
      }]
    }]
  }'
```

Check the collector debug output to see the trace:
```bash
docker logs otel-collector 2>&1 | grep -A 10 "test-span"
```
![task3](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/1fad84ce629f318f4d0c9f073ac8a5fecb270a54/2026/day-76/images/task%203.jpg)

You should see the span details printed to the console. In a production setup, you would send these to a trace backend like Jaeger or Grafana Tempo for storage and visualization.

**Send OTLP metrics too:**
```bash
curl -X POST http://localhost:4318/v1/metrics \
  -H "Content-Type: application/json" \
  -d '{
    "resourceMetrics": [{
      "resource": {
        "attributes": [{
          "key": "service.name",
          "value": { "stringValue": "my-test-service" }
        }]
      },
      "scopeMetrics": [{
        "metrics": [{
          "name": "test_requests_total",
          "sum": {
            "dataPoints": [{
              "asInt": "42",
              "startTimeUnixNano": "1544712660000000000",
              "timeUnixNano": "1544712661000000000"
            }],
            "aggregationTemporality": 2,
            "isMonotonic": true
          }
        }]
      }]
    }]
  }'
```

Now query it in Prometheus:
```promql
test_requests_total
```
![task3.1](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/1fad84ce629f318f4d0c9f073ac8a5fecb270a54/2026/day-76/images/test%203.1.jpg)

The metric traveled: your curl command -> OTEL Collector (OTLP receiver) -> Prometheus exporter -> Prometheus scraped it. This is how OTEL bridges different telemetry formats.

---

### Task 4: Set Up Prometheus Alerting Rules
Alerts notify you when something is wrong. Prometheus evaluates alerting rules and fires alerts when conditions are met.

Create an alerting rules file `alert-rules.yml`:
```yaml
groups:
  - name: system-alerts
    rules:
      - alert: HighCPUUsage
        expr: 100 - (avg(rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 80
        for: 2m
        labels:
          severity: warning
        annotations:
          summary: "High CPU usage detected"
          description: "CPU usage has been above 80% for more than 2 minutes. Current value: {{ $value }}%"

      - alert: HighMemoryUsage
        expr: (1 - node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes) * 100 > 85
        for: 2m
        labels:
          severity: warning
        annotations:
          summary: "High memory usage detected"
          description: "Memory usage is above 85%. Current value: {{ $value }}%"

      - alert: ContainerDown
        expr: absent(container_last_seen{name="notes-app"})
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Container is down"
          description: "The notes-app container has not been seen for over 1 minute"

      - alert: TargetDown
        expr: up == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Scrape target is down"
          description: "{{ $labels.job }} target {{ $labels.instance }} is unreachable"

      - alert: HighDiskUsage
        expr: (1 - node_filesystem_avail_bytes{mountpoint="/"} / node_filesystem_size_bytes{mountpoint="/"}) * 100 > 90
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "Disk space running low"
          description: "Root filesystem usage is above 90%. Current value: {{ $value }}%"
```

**What each alert does:**
- `expr` -- the PromQL condition that triggers the alert
- `for` -- how long the condition must be true before firing (avoids flapping)
- `labels` -- metadata for routing (severity: warning vs critical)
- `annotations` -- human-readable description

Update `prometheus.yml` to load the rules:
```yaml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

rule_files:
  - /etc/prometheus/alert-rules.yml

scrape_configs:
  - job_name: "prometheus"
    static_configs:
      - targets: ["localhost:9090"]

  - job_name: "node-exporter"
    static_configs:
      - targets: ["node-exporter:9100"]

  - job_name: "cadvisor"
    static_configs:
      - targets: ["cadvisor:8080"]

  - job_name: "otel-collector"
    static_configs:
      - targets: ["otel-collector:8889"]
```

Mount the rules file in `docker-compose.yml` under the Prometheus service:
```yaml
  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
      - ./alert-rules.yml:/etc/prometheus/alert-rules.yml
      - prometheus_data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
    restart: unless-stopped
```

Restart Prometheus:
```bash
docker compose up -d prometheus
```

Check the rules in the Prometheus UI: go to Status > Rules. You should see all five alert rules listed.

![task4](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/1fad84ce629f318f4d0c9f073ac8a5fecb270a54/2026/day-76/images/task%204.jpg)

Go to Alerts -- they should be in `inactive` state (green). If any condition is true, the alert moves to `pending`, then `firing` after the `for` duration.

![task4.1](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/1fad84ce629f318f4d0c9f073ac8a5fecb270a54/2026/day-76/images/task%204.1.jpg)

**Test it:** Stop the notes-app container and watch the `TargetDown` alert fire:
```bash
docker compose stop notes-app
```
![task4.2](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/1fad84ce629f318f4d0c9f073ac8a5fecb270a54/2026/day-76/images/task%204.2.jpg)

![task4.3](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/1fad84ce629f318f4d0c9f073ac8a5fecb270a54/2026/day-76/images/task%204.3.jpg)

Wait 1-2 minutes, then check Alerts in the Prometheus UI. Start it back up when done:
```bash
docker compose start notes-app
```

---

### Task 5: Set Up Grafana Alerts
Grafana can also evaluate alerts and send notifications to Slack, email, PagerDuty, and more.

1. **Create a contact point:**
   - Go to Alerting > Contact points > Add contact point
   - Name: "DevOps Team"
   - Integration: Choose email (or Slack webhook if you have one)
   - For email: just enter your email address
   - Save

![task5](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/3949547015778edf36fe34b0269114895f801a5d/2026/day-76/images/task%205.1.jpg)

2. **Create an alert rule in Grafana:**
   - Go to Alerting > Alert rules > New alert rule
   - Name: "High Container Memory"
   - Query: `container_memory_usage_bytes{name="notes-app"} / 1024 / 1024`
   - Condition: IS ABOVE 100 (fire if container uses more than 100MB)
   - Evaluation: every 1m, for 2m
   - Add label: severity = warning
   - Link to the "DevOps Team" contact point
   - Save

3. **Create a notification policy:**
   - Go to Alerting > Notification policies
   - Set the default contact point to "DevOps Team"
   - Add a nested policy: match label `severity=critical` -> route to a different contact point (or the same one with different settings)


4. **View alert state:**
   - Go to Alerting > Alert rules
   - You should see your rule in Normal, Pending, or Firing state

![task5.1](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/3949547015778edf36fe34b0269114895f801a5d/2026/day-76/images/task%205.jpg)

**Document:** What is the difference between Prometheus alerts and Grafana alerts?

- Prometheus alerts are defined in PromQL and evaluated by the Prometheus server. They are great for monitoring infrastructure and services that expose metrics to Prometheus.
- Grafana alerts are defined in the Grafana UI and can be based on any data source (Prometheus, Loki, Tempo, etc). They are more flexible and can be used for application-level monitoring or custom dashboards. You might use Prometheus alerts for low-level system metrics and Grafana alerts for higher-level application metrics or custom conditions that are easier to express in the UI.

When would you use each?
- Use Prometheus alerts for infrastructure monitoring (CPU, memory, disk, network) and service health (up/down).
- Use Grafana alerts for application-level monitoring (response times, error rates) or when you want to create custom dashboards with alerting directly from the UI.

---

### Task 6: Review the Full Stack Architecture
Your observability stack now covers all three pillars. Map out what you have built:

```
                    METRICS PIPELINE
[Node Exporter] -----> [Prometheus] -----> [Grafana Dashboards]
[cAdvisor] ----------> [Prometheus] -----> [Grafana Dashboards]
[OTEL Collector:8889]> [Prometheus] -----> [Grafana Dashboards]
                                    -----> [Alert Rules -> Notifications]

                    LOGS PIPELINE
[Docker Containers] -> [Promtail] -> [Loki] -> [Grafana Explore/Dashboards]

                    TRACES PIPELINE
[curl/App OTLP] -----> [OTEL Collector] -> [Debug Output / Future: Jaeger/Tempo]
```

**Services running:**

| Service | Port | Purpose |
|---------|------|---------|
| Prometheus | 9090 | Metrics storage and querying |
| Node Exporter | 9100 | Host system metrics |
| cAdvisor | 8080 | Container metrics |
| Grafana | 3000 | Visualization and alerting |
| Loki | 3100 | Log storage |
| Promtail | 9080 | Log collection agent |
| OTEL Collector | 4317/4318/8889 | Telemetry collection |
| Notes App | 8000 | Sample application |

Verify all services are running:
```bash
docker compose ps
```

All 8 containers should be healthy and running.

![task6](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/3949547015778edf36fe34b0269114895f801a5d/2026/day-76/images/task%206.jpg)

---

## The full architecture diagram with all three pillars

```
                        ┌───────────────────────────┐
                        │        Grafana            │
                        │ Dashboards & Alerting     │
                        └────────────┬──────────────┘
                                     │
           ┌─────────────────────────┼─────────────────────────┐
           │                         │                         │

      📊 METRICS                📜 LOGS                    🔍 TRACES
           │                         │                         │

 ┌─────────▼─────────┐     ┌────────▼────────┐     ┌──────────▼──────────┐
 │    Prometheus     │     │      Loki       │     │  OTEL Collector     │
 │ (Metrics Storage) │     │ (Log Storage)   │     │ (Telemetry Gateway) │
 └─────────┬─────────┘     └────────┬────────┘     └──────────┬──────────┘
           │                         │                         │
   ┌───────┼────────┐         ┌──────┼───────┐          ┌──────┼────────┐
   │       │        │         │              │          │               │

┌──▼───┐ ┌─▼────┐ ┌─▼────┐  ┌─▼────────┐  ┌─▼───────┐  ┌─▼────────┐  ┌─▼────────┐
│Node  │ │cAdvisor│ │App   │  │Promtail  │  │Containers│  │Application│  │Test/OTLP │
│Exporter││       │ │Metrics│ │(Log Agent)│ │Logs       │ │Traces     │  │Requests   │
└──────┘ └───────┘ └───────┘  └──────────┘  └──────────┘  └──────────┘  └──────────┘

```