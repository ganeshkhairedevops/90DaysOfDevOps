# Day 58 – Metrics Server and Horizontal Pod Autoscaler (HPA)


## What is Metrics Server
Metrics Server collects CPU and memory usage metrics from nodes and pods. HPA relies on it to adjust the number of replicas based on real usage.
### 🔹 Why it is needed:
- Required for `kubectl top`
- Required for **Horizontal Pod Autoscaler (HPA)**

## How HPA calculates desired replicas
Formula: `desiredReplicas = ceil(currentReplicas * (currentUsage / targetUsage))`

- Example: 1 pod using 100m CPU, target 50m → scale to 2 pods.

## Difference between autoscaling/v1 and v2
- **v1**: CPU only, less configurable.
- **v2**: CPU + memory + custom metrics, allows behavior and scaling policies.

---

## Task 1: Install the Metrics Server
The Metrics Server collects CPU and memory usage metrics from all nodes and pods. HPA relies on this data to make scaling decisions.

1. Check if Metrics Server is running:
```bash
kubectl get pods -n kube-system | grep metrics-server
```
2. Install if not present:
- Minikube:
```bash
minikube addons enable metrics-server
```
- Kind/kubeadm: apply the official manifest from the metrics-server GitHub releases
```bash
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```
3. On local clusters, you may need the `--kubelet-insecure-tls` flag (never in production)
 - Patch the Metrics Server to allow insecure TLS
   
   Edit the deployment directly: 
   ```bash
   kubectl edit deployment metrics-server -n kube-system
   ```
   Add this argument under `containers.args:`
   ```yaml
   - --kubelet-insecure-tls
   ```
   After editing, the args section should look like:
   ```yaml
   args:
   - --cert-dir=/tmp
   - --secure-port=4443
   - --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname
   - --kubelet-insecure-tls
   ```
    ![task1.1](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/1cf18aee6b95c9d31d44b89f32ec903662ec42b2/2026/day-58/images/task1.1.jpg)

   Verify Metrics Server is running
   ```bash
   kubectl get pods -n kube-system | grep metrics-server
   ```

![task1](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/1cf18aee6b95c9d31d44b89f32ec903662ec42b2/2026/day-58/images/task%201.jpg)

4. Wait ~60 seconds, then verify metrics collection:
```bash
kubectl top nodes
kubectl top pods -A
```
**Verify:** What is the current CPU and memory usage of your node?

- CPU usage (cores):  232m
- CPU (%): 3% 
- Memory usages (bytes): 1158Mi 
- Memory (%): 14%

![task1.2](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/1cf18aee6b95c9d31d44b89f32ec903662ec42b2/2026/day-58/images/task%201.2.jpg)

---
## Task 2: Explore kubectl top
1. Run `kubectl top nodes`, `kubectl top pods -A`, `kubectl top pods -A --sort-by=cpu`
- `kubectl top nodes` → Shows CPU/memory usage per node.
- `kubectl top pods -A` → Shows usage per pod across all namespaces.
`kubectl top pods -A --sort-by=cpu` → Sort by CPU usage.
2. kubectl top shows real-time usage, not requests or limits — these are different things
3. Data comes from the Metrics Server, which polls kubelets every 15 seconds

**Verify:** Which pod is using the most CPU right now?
- kube-apiserver-devops-control-plane  

![task2](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/1cf18aee6b95c9d31d44b89f32ec903662ec42b2/2026/day-58/images/task%202.jpg)

---
## Task 3: Create a Deployment with CPU Requests
1. Write a Deployment manifest using the registry.k8s.io/hpa-example image (a CPU-intensive PHP-Apache server)
2. Set resources.requests.cpu: 200m — HPA needs this to calculate utilization percentages
3. Expose it as a Service: kubectl expose deployment php-apache --port=80

**Deployment manifest (php-apache-deployment.yaml):**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: php-apache
spec:
  replicas: 1
  selector:
    matchLabels:
      app: php-apache
  template:
    metadata:
      labels:
        app: php-apache
    spec:
      containers:
      - name: php-apache
        image: registry.k8s.io/hpa-example
        ports:
        - containerPort: 80
        resources:
          requests:
            cpu: 200m
```
Apply:
```bash
kubectl apply -f php-apache-deployment.yaml
```
Expose the deployment:
```bash
kubectl expose deployment php-apache --port=80
```
Check CPU usage:
```bash
kubectl top pods
or
kubectl top pod -l app=php-apache
```
![task3](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/1cf18aee6b95c9d31d44b89f32ec903662ec42b2/2026/day-58/images/task%203.jpg)

Without CPU requests, HPA cannot work — this is the most common HPA setup mistake.

**Verify:** What is the current CPU usage of the Pod?
- CPU (cores): 1m


---

## Task 4: Create an HPA (Imperative)
HPA automatically adjusts the number of replicas based on CPU usage.
1. Run: kubectl autoscale deployment php-apache --cpu-percent=50 --min=1 --max=10
2. Check: kubectl get hpa and kubectl describe hpa php-apache
3. TARGETS may show <unknown> initially — wait 30 seconds for metrics to arrive

This scales up when average CPU exceeds 50% of requests, and down when it drops below.

```bash
kubectl autoscale deployment php-apache --cpu-percent=50 --min=1 --max=10
```
Check HPA:
```bash
kubectl get hpa
kubectl describe hpa php-apache
```
![task4.1](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/1cf18aee6b95c9d31d44b89f32ec903662ec42b2/2026/day-58/images/task%204.1.jpg)

**Verify:** What does the TARGETS column show?
- TARGETS: 0%/50%

![task4](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/1cf18aee6b95c9d31d44b89f32ec903662ec42b2/2026/day-58/images/task%204.jpg)

---
## Task 5: Generate Load and Watch Autoscaling

1. Generate CPU load:
```bash
kubectl run load-generator --image=busybox:1.36 --restart=Never -- /bin/sh -c "while true; do wget -q -O- http://php-apache; done"
```
2. Watch HPA:
```bash
kubectl get hpa php-apache --watch
```
![task5.1](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/1cf18aee6b95c9d31d44b89f32ec903662ec42b2/2026/day-58/images/task%205.jpg)

3. Over 1-3 minutes, CPU climbs above 50%, replicas increase, CPU stabilizes
4. Stop the load generator:
```bash
kubectl delete pod load-generator
```
5. Scale-down is slow (5-minute stabilization window) — you do not need to wait

**Verify:** How many replicas did HPA scale to under load?

replicas: 10

![task5](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/1cf18aee6b95c9d31d44b89f32ec903662ec42b2/2026/day-58/images/task%205.1.jpg)

---
## Task 6: Create an HPA from YAML (Declarative)
1. Delete the imperative HPA: 
```bash
kubectl delete hpa php-apache
```
2. Create a HPA manifest using `autoscaling/v2` API with CPU target at 50% utilization
3. Add a `behavior` section to control scale-up speed (no stabilization) and scale-down speed (300 second window)

**php-apache-hpa.yaml**
```bash
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: php-apache
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: php-apache
  minReplicas: 1
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 50
  behavior:
    scaleUp:
      policies:
      - type: Percent
        value: 100
        periodSeconds: 15
      selectPolicy: Max
    scaleDown:
      stabilizationWindowSeconds: 300
```
4. Apply and verify: 
```bash
kubectl apply -f php-apache-hpa.yaml
kubectl describe hpa php-apache
```

`autoscaling/v2` supports multiple metrics and fine-grained scaling behavior that the imperative command cannot configure.

![task6](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/1cf18aee6b95c9d31d44b89f32ec903662ec42b2/2026/day-58/images/task%206.jpg)

`Verify:` What does the behavior section control?
 
The behavior section controls how quickly the HPA scales pods up or down and adds stabilization windows to prevent rapid fluctuations.

- scaleUp → speed of adding pods
- scaleDown → speed of removing pods (with a delay to avoid flapping)


### autoscaling/v1 vs v2

| Feature          | v1       | v2                  |
| ---------------- | -------- | ------------------- |
| Metrics          | CPU only | CPU, Memory, Custom |
| Behavior control | ❌ No     | ✅ Yes            |
| Flexibility      | Limited  | Advanced            |


---

## Task 7: Clean Up

Delete the HPA, Service, Deployment, and load-generator pod. Leave the Metrics Server installed.

```bash
kubectl delete hpa php-apache
kubectl delete service php-apache
kubectl delete deployment php-apache
kubectl delete pod load-generator
```

![task7](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/1cf18aee6b95c9d31d44b89f32ec903662ec42b2/2026/day-58/images/task%207.jpg)

