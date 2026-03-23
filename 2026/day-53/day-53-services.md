# Day 53 – Kubernetes Services

## Why Services?

Every Pod gets its own IP address. But there are two problems:
1. Pod IPs are **not stable** — when a Pod restarts or gets replaced, it gets a new IP
2. A Deployment runs **multiple Pods** — which IP do you connect to?

A Service solves both problems. It provides:
- A **stable IP and DNS name** that never changes
- **Load balancing** across all Pods that match its selector

```
[Client] --> [Service (stable IP)] --> [Pod 1]
                                   --> [Pod 2]
                                   --> [Pod 3]
```

---

## Challenge Tasks

### Task 1: Deploy the Application
First, create a Deployment that you will expose with Services. Create `app-deployment.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
  labels:
    app: web-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web-app
  template:
    metadata:
      labels:
        app: web-app
    spec:
      containers:
      - name: nginx
        image: nginx:1.25
        ports:
        - containerPort: 80
```
```bash
kubectl apply -f app-deployment.yaml
kubectl get pods -o wide
```
Note the individual Pod IPs. These will change if pods restart — that is the problem Services fix.

**Verify:** Are all 3 pods running?
- YES

![task1](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/7c1edd16c09165ca393751447c17232bd6f0ffbb/2026/day-53/images/task%201.jpg)

---
### Task 2: ClusterIP Service (Internal Access)
ClusterIP is the default Service type. It gives your Pods a stable internal IP that is only reachable from within the cluster.

Create `clusterip-service.yaml:`

```yaml
apiVersion: v1
kind: Service
metadata:
  name: web-app-clusterip
spec:
  type: ClusterIP
  selector:
    app: web-app
  ports:
  - port: 80
    targetPort: 80
```
```bash
kubectl apply -f clusterip-service.yaml
kubectl get services
```
Key fields:
- `selector.app: web-app` — this Service routes traffic to all Pods with the label `app: web-app`
- `port: 80` — the port the Service listens on
- `targetPort: 80` — the port on the Pod to forward traffic to

```bash
kubectl apply -f clusterip-service.yaml
kubectl get services
```
![task2](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/7c1edd16c09165ca393751447c17232bd6f0ffbb/2026/day-53/images/task%202.jpg)

You should see `web-app-clusterip` with a CLUSTER-IP address. This IP is stable — it will not change even if Pods restart.

Now test it from inside the cluster:
```bash
# Run a temporary pod to test connectivity
kubectl run test-client --image=busybox:latest --rm -it --restart=Never -- sh

# Inside the test pod, run:
wget -qO- http://web-app-clusterip
exit
```

You should see the Nginx welcome page. The Service load-balanced your request to one of the 3 Pods.

![task2.1](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/7c1edd16c09165ca393751447c17232bd6f0ffbb/2026/day-53/images/task%202.1.jpg)

**Verify:** Does the Service respond? Try running the wget command multiple times — the Service distributes traffic across all healthy Pods.
- YES 

---

### Task 3: Discover Services with DNS
Services are discoverable via DNS. The Service name becomes a hostname that resolves to the Service's ClusterIP.

Kubernetes has a built-in DNS server. Every Service gets a DNS entry automatically:

```
<service-name>.<namespace>.svc.cluster.local
```

Test this:
```bash
kubectl run dns-test --image=busybox:latest --rm -it --restart=Never -- sh

# Inside the pod:
# Short name (works within the same namespace)
wget -qO- http://web-app-clusterip

# Full DNS name
wget -qO- http://web-app-clusterip.default.svc.cluster.local

# Look up the DNS entry
nslookup web-app-clusterip
exit
```

Both the short name and the full DNS name resolve to the same ClusterIP. In practice, you use the short name when communicating within the same namespace and the full name when reaching across namespaces.

**Verify:** What IP does `nslookup` return? Does it match the CLUSTER-IP from `kubectl get services`?
- YES, it matches the CLUSTER-IP from `kubectl get services`

![task3](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/7c1edd16c09165ca393751447c17232bd6f0ffbb/2026/day-53/images/task%203.jpg)

![task3.1](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/7c1edd16c09165ca393751447c17232bd6f0ffbb/2026/day-53/images/task%203.1.jpg)

---

### Task 4: NodePort Service (External Access via Node)
A NodePort Service exposes your application on a port on every node in the cluster. This lets you access the Service from outside the cluster.
Create `nodeport-service.yaml`:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: web-app-nodeport
spec:
  type: NodePort
  selector:
    app: web-app
  ports:
  - port: 80
    targetPort: 80
    nodePort: 30080
```

- `nodePort: 30080` — the port opened on every node (must be in range 30000-32767)
- Traffic flow: `<NodeIP>:30080` -> Service -> Pod:80

```bash
kubectl apply -f nodeport-service.yaml
kubectl get services
```
![task4](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/7c1edd16c09165ca393751447c17232bd6f0ffbb/2026/day-53/images/task%204.jpg)

Access the service:
```bash
# If using Minikube
minikube service web-app-nodeport --url

# If using Kind, get the node IP first
kubectl get nodes -o wide
# Then curl <node-internal-ip>:30080

# If using Docker Desktop
curl http://localhost:30080
```

**Verify:** Can you see the Nginx welcome page from your browser or terminal using the NodePort?
- YES, I can see the Nginx welcome page from my browser or terminal using the NodePort.

![task4.1](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/7c1edd16c09165ca393751447c17232bd6f0ffbb/2026/day-53/images/task%204.1.jpg)

---

### Task 5: LoadBalancer Service (Cloud External Access)
In a cloud environment (AWS, GCP, Azure), a LoadBalancer Service provisions a real external load balancer that routes traffic to your nodes.

Create `loadbalancer-service.yaml`:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: web-app-loadbalancer
spec:
  type: LoadBalancer
  selector:
    app: web-app
  ports:
  - port: 80
    targetPort: 80
```

```bash
kubectl apply -f loadbalancer-service.yaml
kubectl get services
```

On a local cluster (Minikube, Kind, Docker Desktop), the EXTERNAL-IP will show `<pending>` because there is no cloud provider to create a real load balancer. This is expected.

If you are using Minikube:
```bash
# Minikube can simulate a LoadBalancer
minikube tunnel
# In another terminal, check again:
kubectl get services
```

In a real cloud cluster, the EXTERNAL-IP would be a public IP address or hostname provisioned by the cloud provider.

**Verify:** What does the EXTERNAL-IP column show? Why is it `<pending>` on a local cluster?
- The EXTERNAL-IP column shows `<pending>` on a local cluster because there is no cloud provider to provision a real load balancer. Local clusters do not have the capability to create external load balancers, so they cannot assign an external IP address to the LoadBalancer Service.

![task5](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/7c1edd16c09165ca393751447c17232bd6f0ffbb/2026/day-53/images/task%205.jpg)

---

### Task 6: Understand the Service Types Side by Side
Check all three services:

```bash
kubectl get services -o wide
```

Compare them:

| Type | Accessible From | Use Case |
|------|----------------|----------|
| ClusterIP | Inside the cluster only | Internal communication between services |
| NodePort | Outside via `<NodeIP>:<NodePort>` | Development, testing, direct node access |
| LoadBalancer | Outside via cloud load balancer | Production traffic in cloud environments |

Each type builds on the previous one:
- LoadBalancer creates a NodePort, which creates a ClusterIP
- So a LoadBalancer service also has a ClusterIP and a NodePort

Verify this:
```bash
kubectl describe service web-app-loadbalancer
```

You should see all three: a ClusterIP, a NodePort, and the LoadBalancer configuration.

**Verify:** Does the LoadBalancer service also have a ClusterIP and NodePort assigned?
- YES, the LoadBalancer service also has a ClusterIP and NodePort assigned. When you create a LoadBalancer service, Kubernetes automatically creates a ClusterIP and a NodePort for it. You can see this in the output of `kubectl describe service web-app-loadbalancer`, which will show the ClusterIP, NodePort, and LoadBalancer details.

![task6](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/7c1edd16c09165ca393751447c17232bd6f0ffbb/2026/day-53/images/task%206.jpg)

---

### Task 7: Clean Up
```bash
kubectl delete -f app-deployment.yaml
kubectl delete -f clusterip-service.yaml
kubectl delete -f nodeport-service.yaml
kubectl delete -f loadbalancer-service.yaml

kubectl get pods
kubectl get services
```

Only the built-in `kubernetes` service in the default namespace should remain.

**Verify:** Is everything cleaned up?
- YES, everything is cleaned up. After running the delete commands, you should see that all the pods and services you created have been removed, leaving only the default `kubernetes` service in the default namespace when you run `kubectl get services`.

![task7](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/7c1edd16c09165ca393751447c17232bd6f0ffbb/2026/day-53/images/task%207.jpg)

---
**What problem Services solve and how they relate to Pods and Deployments**
- Services provide a stable IP and DNS name for a set of Pods
- Services load balance traffic across all Pods that match their selector
- Services decouple the client from the Pods, allowing Pods to be replaced or scaled without affecting clients

**Your three Service manifests with an explanation of each type**
`ClusterIP Service`

```bash
apiVersion: v1
kind: Service
metadata:
  name: web-app-clusterip
spec:
  type: ClusterIP
  selector:
    app: web-app
  ports:
  - port: 80
    targetPort: 80
```
- Default Service type
- Exposes Pods inside the cluster only
- Provides a stable internal IP + DNS name
- Used for internal communication between services


`NodePort Service`

```bash
apiVersion: v1
kind: Service
metadata:
  name: web-app-nodeport
spec:
  type: NodePort
  selector:
    app: web-app
  ports:
  - port: 80
    targetPort: 80
    nodePort: 30080
```
- Exposes Service on each node’s IP at a fixed port (30000–32767)
- Access using: `<NodeIP>:NodePort`
- Used for external access in development/testing


`LoadBalancer Service`

```bash
apiVersion: v1
kind: Service
metadata:
  name: web-app-loadbalancer
spec:
  type: LoadBalancer
  selector:
    app: web-app
  ports:
    - port: 80
      targetPort: 80
```
- Creates an external load balancer (in cloud environments)
- Provides a public IP to access the app
- Used for production external traffic
- Internally also includes ClusterIP + NodePort

**The difference between ClusterIP, NodePort, and LoadBalancer**
- ClusterIP: Internal access only, stable IP within the cluster
- NodePort: Exposes the service on a port on each node, allowing external access
- LoadBalancer: Provisions an external load balancer in cloud environments, providing a single IP for external access and load balancing across nodes and pods

**How Kubernetes DNS works for service discovery**
- Kubernetes has a built-in DNS server that automatically creates DNS entries for Services
- Services can be accessed using their DNS name, which resolves to the Service's ClusterIP
- The DNS name format is `<service-name>.<namespace>.svc.cluster.local`

**What Endpoints are and how to inspect them**
- Endpoints are the actual IP addresses of the Pods that a Service routes to
- You can inspect Endpoints using `kubectl get endpoints <service-name>` or `kubectl describe service <service-name>`
- Endpoints show which Pods are currently healthy and receiving traffic from the Service

---
