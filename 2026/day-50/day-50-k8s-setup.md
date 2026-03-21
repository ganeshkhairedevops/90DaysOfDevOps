# Day 50 – Kubernetes Architecture and Cluster Setup

## Kubernetes History (In My Own Words)

### Task 1: Recall the Kubernetes Story

1. Why was Kubernetes created? What problem does it solve that Docker alone cannot?
- Kubernetes was created to solve the problem of managing and scaling containers across multiple machines, something Docker alone cannot handle efficiently. While Docker helps in creating and running containers, it does not provide orchestration features like auto-scaling, self-healing, and load balancing.

2. Who created Kubernetes and what was it inspired by?
- Kubernetes was originally developed by `Google` and inspired by their internal system called `Borg`. It was later open-sourced and is now maintained by the `Cloud Native Computing Foundation` (CNCF) in 2014.

3. What does the name "Kubernetes" mean?
- The name "Kubernetes" comes from Greek, meaning "helmsman" or "pilot," symbolizing its role in steering containerized applications.
- Kubernetes is often shortened to K8s, where the number 8 represents the eight letters between K and S.

---

## 🏗️ Kubernetes Architecture (Text Diagram)
### Task 2: Draw the Kubernetes Architecture
### Control Plane (Master Node)

- **API Server**
  - Entry point to the cluster
  - All commands (`kubectl`) go through it

- **etcd**
  - Key-value store
  - Stores cluster state and configuration

- **Scheduler**
  - Assigns pods to appropriate worker nodes

- **Controller Manager**
  - Ensures desired state matches actual state
  - Handles replication, node health, etc.

**Control Plane (Master Node):**
- API Server — the front door to the cluster, every command goes through it
- etcd — the database that stores all cluster state
- Scheduler — decides which node a new pod should run on
- Controller Manager — watches the cluster and makes sure the desired state matches reality

**Worker Node:**
- kubelet — the agent on each node that talks to the API server and manages pods
- kube-proxy — handles networking rules so pods can communicate
- Container Runtime — the engine that actually runs containers (containerd, CRI-O)

---

### Worker Node

- **kubelet**
  - Agent on each node
  - Communicates with API server
  - Ensures containers are running

- **kube-proxy**
  - Manages networking
  - Enables communication between pods

- **Container Runtime**
  - Runs containers (e.g., containerd, CRI-O)

## Kubernetes Architecture
![image](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/e666565ed81d5ba1365491f99ea7d5f3df59753d/2026/day-50/images/kubernetes%20architecture%20diagram.png)

---

### What Happens When You Run `kubectl apply -f pod.yaml`?

1. Command hits **API Server**
2. API Server validates request
3. Configuration stored in **etcd**
4. **Scheduler** assigns pod to a node
5. **kubelet** on that node creates the pod
6. Container runtime runs the container

---

### What happens if the API server goes down?

- **If API Server goes down:**
  - Cluster becomes unmanageable (no new changes possible)
### What happens if a worker node goes down?
- **If Worker Node goes down:**
  - Pods on that node fail
  - Controller reschedules them on other nodes

---
## Task 3: Install kubectl
### Task 3: Install kubectl
`kubectl` is the CLI tool you will use to talk to your Kubernetes cluster.

```bash
# Linux (amd64)
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
```

Verify:
```bash
kubectl version --client
```
![task 3](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/c6c5c6c8dd0a4695d84f60a25329713266e9b655/2026/day-50/images/task%203.jpg)

---

### Task 4: Set Up Your Local Cluster
## 🛠️ Tool Chosen: kind (Kubernetes in Docker)

#### Install Kind
```bash
# Linux
curl -Lo ./kind https://kind.sigs.k8s.io/dl/latest/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind
```
#### Create a cluster
```bash
kind create cluster --name devops-cluster
```
![image](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/c6c5c6c8dd0a4695d84f60a25329713266e9b655/2026/day-50/images/task%204.jpg)

#### Verify
```bash
kubectl cluster-info
kubectl get nodes
```
![task](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/c6c5c6c8dd0a4695d84f60a25329713266e9b655/2026/day-50/images/task%205.jpg)


### ✅ Why I chose kind:
- Lightweight and fast
- Runs Kubernetes inside Docker containers
- Ideal for local DevOps practice
- Easy setup and teardown

---

### Task 5: Explore Your Cluster

**Get detailed info about your node**
```bash
kubectl describe node devops-cluster-control-plane
```
**List All Nampspaces**
```bash
kubectl get namespaces
```
**See ALL pods running in the cluster (across all namespaces)**
```bash
kubectl get pods -A
```
![task5](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/c6c5c6c8dd0a4695d84f60a25329713266e9b655/2026/day-50/images/task%205.jpg)

### Status
**Look at the pods running in the kube-system namespace:**
```bash
kubectl get pods -n kube-system
```
![task5.1](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/c6c5c6c8dd0a4695d84f60a25329713266e9b655/2026/day-50/images/task%205.1.jpg)



### Task 6: Practice Cluster Lifecycle

### Delete your cluster
```bash
kind delete cluster --name devops-cluster
```
![task6](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/c6c5c6c8dd0a4695d84f60a25329713266e9b655/2026/day-50/images/task%206.jpg)

### Create Cluster
```bash
kind create cluster --name devops-cluster
```
### Check which cluster kubectl is connected to
```bash
kubectl config current-context
```
### List all available contexts (clusters)
```bash
kubectl config get-contexts
```
### See the full kubeconfig
```bash
kubectl config view
```
![task6.1](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/c6c5c6c8dd0a4695d84f60a25329713266e9b655/2026/day-50/images/task%206.1.jpg)

What is a kubeconfig? Where is it stored on your machine?
- A kubeconfig is a configuration file that contains information about clusters, users, and contexts. It allows `kubectl` to communicate with the Kubernetes API server. By default, it is stored at `~/.kube/config` on your machine.
