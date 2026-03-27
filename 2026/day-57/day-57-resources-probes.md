# Day 57 – Resource Requests, Limits, and Probes

## Requests vs limits (scheduling vs enforcement)
- Requests: What the container needs to run (used by scheduler)
- Limits: What the container is allowed to use (enforced by kubelet)

Kubernetes uses **requests and limits** to manage resources.

### 🔹 Requests
- Minimum resources guaranteed
- Used by scheduler for pod placement

### 🔹 Limits
- Maximum resources allowed
- Enforced by kubelet at runtime

---
# Challenge Tasks
## Task 1: Resource Requests and Limits
1. Write a Pod manifest with `resources.requests` (cpu: 100m, memory: 128Mi) and `resources.limits` (cpu: 250m, memory: 256Mi)
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
    containers:
    - name: app
      image: nginx
      ports:
       - containerPort: 80
      resources:
        requests:
          cpu: "100m"
          memory: "128Mi"
        limits:
          cpu: "250m"
          memory: "256Mi"

```
2. Apply and inspect with `kubectl describe pod` — look for the Requests, Limits, and QoS Class sections
```bash
kubectl apply -f pod.yaml
kubectl describe pod nginx
```
3. Since requests and limits differ, the QoS class is `Burstable`. If equal, it would be `Guaranteed`. If missing, `BestEffort`.
CPU is in millicores: `100m` = 0.1 CPU. Memory is in mebibytes: `128Mi`.

**Requests** = guaranteed minimum (scheduler uses this for placement). **Limits** = maximum allowed (kubelet enforces at runtime).

**Verify:** What QoS class does your Pod have?

The QoS class for this Pod is `Burstable` because the requests and limits differ.

![task1](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/65c7697d7052af572e315163a6724f71b7dcbf34/2026/day-57/images/task%201.jpg)

---
## Task 2: OOMKilled — Exceeding Memory Limits

1. Create a Pod that exceeds its memory limit (e.g., `memory: 100Mi` limit but the container tries to use more)
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: memory-stress
spec:
  containers:
  - name: stress
    image: polinux/stress
    command: ["stress"]
    args: ["--vm", "1", "--vm-bytes", "200M", "--vm-hang", "1"]
    resources:
      limits:
        memory: "100Mi"
```
2. Apply and monitor the Pod status
```bash
kubectl apply -f memory-stress.yaml
kubectl get pods memory-stress -w
kubectl describe pod memory-stress
```
3. After a short time, the Pod will be marked as `OOMKilled` due to exceeding the memory limit.

**Verify:** What event indicates the Pod was killed due to memory limits?
The event indicating the Pod was killed due to memory limits is `OOMKilled` in the Pod status.


---

## Task 3: Pending Pod — Requesting Too Much
1. Create a Pod with a cpu: 100 and memory: 128Gi
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: pending
spec:
  containers:
  - name: nginx
    image: nginx
    resources:
      requests:
        cpu: "100"
        memory: "128Gi"
```
2. Apply and monitor the Pod status
```bash
kubectl apply -f pending.yaml
kubectl get pods pending -w
```
3. The Pod will remain in `Pending` state because the requested resources exceed cluster capacity.

**Verify:** Why is the Pod stuck in Pending?
The Pod is stuck in Pending because the requested CPU (100 cores) and memory (128Gi) exceed the available resources in the cluster, preventing the scheduler from placing it on any node.

![task3](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/65c7697d7052af572e315163a6724f71b7dcbf34/2026/day-57/images/task%203.jpg)

---

## Task 4: Liveness Probes
A liveness probe detects stuck containers. If it fails, Kubernetes restarts the container.
1. Create a Pod manifest with a busybox container that creates /tmp/healthy on startup, then deletes it after 30 seconds
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: liveness
spec:
  containers:
  - name: busybox
    image: busybox
    command:
      - sh
      - -c
      - |
        touch /tmp/healthy
        sleep 30
        rm -f /tmp/healthy
        sleep 600
    livenessProbe:
      exec:
        command:
        - cat
        - /tmp/healthy
      periodSeconds: 5
      failureThreshold: 3
```
2. Apply and monitor the Pod status
```bash
kubectl apply -f liveness.yaml
kubectl get pods liveness -w
```
![task4](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/65c7697d7052af572e315163a6724f71b7dcbf34/2026/day-57/images/task%204.jpg)


3. After 30 seconds, the liveness probe will fail and Kubernetes will restart the container.

![task4.1](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/65c7697d7052af572e315163a6724f71b7dcbf34/2026/day-57/images/task%204.1.jpg)

**Verify:** How many times has the container restarted?
 7 times 

 ![task4.2](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/65c7697d7052af572e315163a6724f71b7dcbf34/2026/day-57/images/task%204.2.jpg)

---

## Task 5: Readiness Probes
A readiness probe controls traffic. Failure removes the Pod from Service endpoints but does NOT restart it.
1. Create a Pod manifest with nginx and a readinessProbe using httpGet on path / port 80
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: readiness
  labels:
    app: nginx
spec:
  containers:
  - name: nginx
    image: nginx
    readinessProbe:
      httpGet:
        path: /
        port: 80
      periodSeconds: 5
```
Apply and monitor the Pod status
```bash
kubectl apply -f readiness.yaml
kubectl get pods readiness -w
```
![task5](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/65c7697d7052af572e315163a6724f71b7dcbf34/2026/day-57/images/task%205.jpg)

2. Expose it as a Service: kubectl expose pod <name> --port=80 --name=readiness-svc
```bash
kubectl expose pod readiness --port=80 --name=readiness-svc
```
![task5.1](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/65c7697d7052af572e315163a6724f71b7dcbf34/2026/day-57/images/task%205.1.jpg)

3. Check kubectl get endpoints readiness-svc — the Pod IP is listed
```bash
kubectl get endpoints readiness-svc
```
4. Break the probe: kubectl exec <pod> -- rm /usr/share/nginx/html/index.html
```bash
kubectl exec readiness -- rm /usr/share/nginx/html/index.html
```
5. Wait 15 seconds — Pod shows 0/1 READY, endpoints are empty, but the container is NOT restarted
```bash
kubectl get pods readiness
kubectl get endpoints readiness-svc
```
![task5.2](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/65c7697d7052af572e315163a6724f71b7dcbf34/2026/day-57/images/task%205.3.jpg)

**Verify:**When readiness failed, was the container restarted?
No, the container was not restarted when the readiness probe failed. The Pod was marked as not ready, and it was removed from the Service endpoints, but it continued running without a restart.

---
## Task 6: Startup Probes
A startup probe gives slow-starting containers extra time. While it runs, liveness and readiness probes are disabled.
1. Write a Pod manifest where the container takes 20 seconds to start (e.g., sleep 20 && touch /tmp/started)
2. Add a startupProbe checking for /tmp/started with periodSeconds: 5 and failureThreshold: 12 (60 second budget)
3. Add a livenessProbe that checks the same file — it only kicks in after startup succeeds
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: startup-probe
spec:
  containers:
  - name: app
    image: busybox
    command:
      - sh
      - -c
      - |
        sleep 20
        touch /tmp/started
        sleep 600
    startupProbe:
      exec:
        command:
        - cat
        - /tmp/started
      periodSeconds: 5
      failureThreshold: 12
    livenessProbe:
      exec:
        command:
        - cat
        - /tmp/started
```
**What Happens Normally (failureThreshold: 12)**
- Startup probe runs every 5 seconds
- Allowed failures = 12
- Total startup time allowed = 60 seconds

 Your app takes 20 seconds, so:

- Probe keeps failing initially ❌
- After 20s → file created ✅
- Startup probe succeeds

**Verify:** What would happen if failureThreshold were 2 instead of 12?

If failureThreshold = 2, the container would be killed before it finishes starting, causing a CrashLoopBackOff.

![task6](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/65c7697d7052af572e315163a6724f71b7dcbf34/2026/day-57/images/task%206.jpg)

---
## Task 7: Clean Up
Delete all pods and services you created.
```bash
kubectl delete -f .
```

![task7](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/65c7697d7052af572e315163a6724f71b7dcbf34/2026/day-57/images/task%207.jpg)

---



