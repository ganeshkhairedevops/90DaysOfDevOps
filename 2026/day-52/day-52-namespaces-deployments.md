# Day 52 – Kubernetes Namespaces and Deployments
## 📦 What Are Namespaces?

Namespaces in Kubernetes are used to **logically separate resources** within a cluster.

### 🔹 Why Use Namespaces?
- Organize resources (dev, staging, production)
- Avoid naming conflicts
- Apply resource limits and access control
- Isolate environments within the same cluster

---

## Challenge Tasks

### Task 1: Explore Default Namespaces
Kubernetes comes with built-in namespaces. List them:

```bash
kubectl get namespaces
```
You should see at least:
- default — where your resources go if you do not specify a namespace
- kube-system — Kubernetes internal components (API server, scheduler, etc.)
- kube-public — publicly readable resources
- kube-node-lease — node heartbeat tracking

Check what is running inside kube-system:
```bash
kubectl get pods -n kube-system
```
These are the control plane components keeping your cluster alive. Do not touch them.

**Verify:** How many pods are running in `kube-system`?

`8 pods are running`

![task1](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/c2ba2f09756fe550fb6d72557a954d8826015dd4/2026/day-52/images/task%201.jpg)

---
### Task 2: Create and Use Custom Namespaces
Create two namespaces — one for a development environment and one for staging:

```bash
kubectl create namespace dev
kubectl create namespace staging
```
Verify they exist:
```bash
kubectl get namespaces
```
You should see `dev` and `staging` in the list.

![task2](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/c2ba2f09756fe550fb6d72557a954d8826015dd4/2026/day-52/images/task%202.png)

You can also create a namespace from a manifest:
```yaml
# namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: production
```
```bash
kubectl apply -f namespace.yaml
```
![task2.1](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/c2ba2f09756fe550fb6d72557a954d8826015dd4/2026/day-52/images/task%202.1.jpg)

Now run a pod in a specific namespace:
```bash
kubectl run nginx-dev --image=nginx:latest -n dev
kubectl run nginx-staging --image=nginx:latest -n staging
```
![task2.2](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/c2ba2f09756fe550fb6d72557a954d8826015dd4/2026/day-52/images/task%202.2.jpg)

List pods across all namespaces:
```bash
kubectl get pods -A
```
![task2.3](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/c2ba2f09756fe550fb6d72557a954d8826015dd4/2026/day-52/images/task%202.3.jpg)

You should see the nginx pods running in their respective namespaces.

Notice that kubectl get pods without -n only shows the default namespace. You must specify -n <namespace> or use -A to see everything.

**Verify:** 
1. Does `kubectl get pods` show these pods?
- No, it only shows pods in the default namespace.

2. What about `kubectl get pods -A`?
- Yes, it shows all pods across all namespaces, including the ones in dev and staging.

---

### Task 3: Create Your First Deployment
A Deployment tells Kubernetes: "I want X replicas of this Pod running at all times." If a Pod crashes, the Deployment controller recreates it automatically.
Create a file `nginx-deployment.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  namespace: dev
  labels:
    app: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.24
        ports:
        - containerPort: 80
```
Apply the deployment:
```bash
kubectl apply -f nginx-deployment.yaml
```
Check the status of the deployment:
```bash
kubectl get deployments -n dev
kubectl get pods -n dev
```
You should see 3 pods running, managed by the Deployment.

![task3](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/c2ba2f09756fe550fb6d72557a954d8826015dd4/2026/day-52/images/task%203.jpg)

**Verify:** What do the READY, UP-TO-DATE, and AVAILABLE columns mean in the deployment output?
- READY: Number of pods that are ready vs desired (e.g., 3/3 means all pods are ready)
- UP-TO-DATE: Number of pods that have been updated to the latest version specified in the deployment
- AVAILABLE: Number of pods that are available to serve traffic (ready and not crashing)
---
### Task 4: Self-Healing — Delete a Pod and Watch It Come Back
This is the key difference between a Deployment and a standalone Pod.

```bash
# List pods
kubectl get pods -n dev

# Delete one of the deployment's pods (use an actual pod name from your output)
kubectl delete pod <pod-name> -n dev

# Immediately check again
kubectl get pods -n dev
```

The Deployment controller detects that only 2 of 3 desired replicas exist and immediately creates a new one. The deleted pod is replaced within seconds.

**Verify:** Is the replacement pod's name the same as the one you deleted, or different?

- Yes,different name but same prefix

![task4](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/c2ba2f09756fe550fb6d72557a954d8826015dd4/2026/day-52/images/task%204.jpg)

---
### Task 5: Scale the Deployment
Change the number of replicas:

```bash
# Scale up to 5
kubectl scale deployment nginx-deployment --replicas=5 -n dev
kubectl get pods -n dev

# Scale down to 2
kubectl scale deployment nginx-deployment --replicas=2 -n dev
kubectl get pods -n dev
```
You should see the number of pods increase to 5 and then decrease to 2 as you scale up and down.

![task5](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/c2ba2f09756fe550fb6d72557a954d8826015dd4/2026/day-52/images/task%205.jpg)

![task5.1](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/c2ba2f09756fe550fb6d72557a954d8826015dd4/2026/day-52/images/task%205.1.jpg)

Watch how Kubernetes creates or terminates pods to match the desired count.
You can also scale by editing the manifest — change `replicas: 4` in your YAML file and run `kubectl apply -f nginx-deployment.yaml` again.

![task5.2](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/c2ba2f09756fe550fb6d72557a954d8826015dd4/2026/day-52/images/task%205.2.jpg)

**Verify:** When you scaled down from 5 to 2, what happened to the extra pods?

- Kubernetes terminated 3 of the pods to match the desired count of 2.

---
### Task 6: Rolling Update
Update the Nginx image version to trigger a rolling update:

```bash
kubectl set image deployment/nginx-deployment nginx=nginx:1.25 -n dev
```

Watch the rollout in real time:
```bash
kubectl rollout status deployment/nginx-deployment -n dev
```

Kubernetes replaces pods one by one — old pods are terminated only after new ones are healthy. This means zero downtime.

Check the rollout history:
```bash
kubectl rollout history deployment/nginx-deployment -n dev
```

![task6](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/c2ba2f09756fe550fb6d72557a954d8826015dd4/2026/day-52/images/task%206.jpg)

Now roll back to the previous version:
```bash
kubectl rollout undo deployment/nginx-deployment -n dev
kubectl rollout status deployment/nginx-deployment -n dev
```

Verify the image is back to the previous version:
```bash
kubectl describe deployment nginx-deployment -n dev | grep Image
```

![task6.1](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/c2ba2f09756fe550fb6d72557a954d8826015dd4/2026/day-52/images/task%206.1.jpg)

**Verify:** What image version is running after the rollback?
- After rollback Image Version is `nginx:1.24`
---

### Task 7: Clean Up
```bash
kubectl delete deployment nginx-deployment -n dev
kubectl delete pod nginx-dev -n dev
kubectl delete pod nginx-staging -n staging
kubectl delete namespace dev staging production
```
This will remove all the resources you created during this challenge and clean up your cluster.

Deleting a namespace removes everything inside it. Be very careful with this in production.

```bash
kubectl get namespaces
kubectl get pods -A
```
![task7](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/c2ba2f09756fe550fb6d72557a954d8826015dd4/2026/day-52/images/task%207.jpg)

**Verify:** Are all your resources gone?
- Yes, all namespaces and pods created during the challenge are deleted.
---

**What namespaces are and why you would use them**
- Namespaces in Kubernetes are a way to logically divide a cluster into multiple virtual environments.
- They are used to keep things organized and isolated (logical isolation) (e.g., stage,dev and prod don’t mix)
- They help avoid naming conflicts (you can have the same pod name in different namespaces)
- They allow you to apply resource limits and access control at the namespace level

**Deployment manifest and explanation of each section**
- `apiVersion: apps/v1` → Required API version for Deployments
- `kind: Deployment` → Defines a controller that manages Pods
- `metadata` → Name, namespace, and labels
- `spec` → Main configuration of the Deployment
- `spec.replicas` → Ensures 3 Pods are always running
- `spec.selector` → Matches Pods with label app: nginx
- `template` → Blueprint for creating Pods
- `containers.image` → Defines which container image to run
- `ports` → Exposes container port 80

**What happens when you delete a Pod managed by a Deployment vs a standalone Pod**
- When you delete a Pod managed by a Deployment, the Deployment controller detects that the desired number of replicas is not met and automatically creates a new Pod to replace the one you deleted. This ensures high availability and self-healing.
- When you delete a standalone Pod (not managed by a Deployment), it is simply removed and will not be recreated. If you want it back, you would have to manually create it again.

**How scaling works (both imperative and declarative)**
- Imperative scaling: You can use the `kubectl scale` command to change the number of replicas on the fly. For example, `kubectl scale deployment nginx-deployment --replicas=5` will immediately scale up to 5 replicas.
- Declarative scaling: You can edit the Deployment manifest YAML file and change the `replicas` field to the desired number. Then apply the changes with `kubectl apply -f nginx-deployment.yaml`. Kubernetes will compare the current state with the desired state and make the necessary adjustments to match the new replica count.

**How rolling updates and rollbacks work**
- Rolling updates allow you to update the application version without downtime. When you change the image version in the Deployment, Kubernetes will create new Pods with the updated image and only terminate old Pods once the new ones are healthy and ready to serve traffic.
- Rollbacks allow you to revert to a previous version if something goes wrong. Kubernetes keeps a history of revisions for each Deployment. If you need to roll back, you can use `kubectl rollout undo` to revert to the last known good state. The new Pods will be replaced with the previous version, again without downtime.
---

You have successfully created namespaces, deployed applications using Deployments, and experienced Kubernetes' self-healing and scaling capabilities.