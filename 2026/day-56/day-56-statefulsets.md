# Day 56 – Kubernetes StatefulSets
## 📦 What are StatefulSets?
StatefulSets are a Kubernetes workload designed for stateful applications that require stable network identities and persistent storage. They provide features like ordered deployment, stable pod names, and persistent volume claims (PVCs) for each replica.

StatefulSets are used to manage **stateful applications** like:
- Databases (MySQL, PostgreSQL)
- Kafka
- Redis clusters

They provide:
- Stable pod identity
- Ordered deployment
- Persistent storage per pod
---
## ⚖️ Deployment vs StatefulSet

| Feature              | Deployment              | StatefulSet                     |
|---------------------|------------------------|--------------------------------|
| Pod names           | Random                 | Stable (web-0, web-1, web-2)   |
| Startup order       | Parallel               | Ordered                        |
| Storage             | Shared / ephemeral     | Unique PVC per pod             |
| Network identity    | No stable hostname     | Stable DNS per pod             |
---
## How Headless Services, stable DNS, and volumeClaimTemplates work
- **Headless Service**: A Service with `clusterIP: None` that creates individual DNS entries for each pod instead of load-balancing to one IP. This allows StatefulSet pods to have stable network identities.
- **Stable DNS**: Each pod in a StatefulSet gets a predictable DNS name based on the `serviceName` and its ordinal index (e.g., `web-0`, `web-1`).
- **volumeClaimTemplates**: A section in the StatefulSet manifest that defines a template for PVCs. Each pod gets its own PVC based on this template, ensuring data persistence even if pods are deleted or rescheduled.
---
## Challenge Tasks

### Task 1: Understand the Problem
1. Create a Deployment with 3 replicas using nginx
2. Check the pod names — they are random (`app-xyz-abc`)
3. Delete a pod and notice the replacement gets a different random name

This is fine for web servers but not for databases where you need stable identity.

| Feature | Deployment | StatefulSet |
|---|---|---|
| Pod names | Random | Stable, ordered (`app-0`, `app-1`) |
| Startup order | All at once | Ordered: pod-0, then pod-1, then pod-2 |
| Storage | Shared PVC | Each pod gets its own PVC |
| Network identity | No stable hostname | Stable DNS per pod |

![task1](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/5c7aa92597e93f4f504eebca8249155d16e806b9/2026/day-56/images/task%201.JPG)

![task1.1](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/5c7aa92597e93f4f504eebca8249155d16e806b9/2026/day-56/images/task%201.1.JPG)

**Verify:** Why would random pod names be a problem for a database cluster?
- Databases rely on stable identity
- Cluster members need fixed hostnames
- Replication and leader election break with changing names
---
### Task 2: Create a Headless Service
1. Write a Service manifest with `clusterIP: None` — this is a Headless Service
2. Set the selector to match the labels you will use on your StatefulSet pods
3. Apply it and confirm CLUSTER-IP shows `None`
A Headless Service creates individual DNS entries for each pod instead of load-balancing to one IP. StatefulSets require this.

![task2](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/5c7aa92597e93f4f504eebca8249155d16e806b9/2026/day-56/images/task%202.JPG)

**Verify:** What does the CLUSTER-IP column show?
- It should show `None` for the Headless Service
---
### Task 3: Create a StatefulSet
1. Write a StatefulSet manifest with `serviceName` pointing to your Headless Service
2. Set replicas to 3, use the nginx image
3. Add a `volumeClaimTemplates` section requesting 100Mi of ReadWriteOnce storage
4. Apply and watch: `kubectl get pods -l <your-label> -w`
Observe ordered creation — `web-0` first, then `web-1` after `web-0` is Ready, then `web-2`.
Check the PVCs: `kubectl get pvc` — you should see `web-data-web-0`, `web-data-web-1`, `web-data-web-2` (names follow the pattern `<template-name>-<pod-name>`).

![task3](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/5c7aa92597e93f4f504eebca8249155d16e806b9/2026/day-56/images/task%203.JPG)


**Verify:** What are the exact pod names and PVC names?
- Pod names: `web-0`, `web-1`, `web-2`
- PVC names: `web-data-web-0`, `web-data-web-1`, `web-data-web-2`

![task3.1](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/5c7aa92597e93f4f504eebca8249155d16e806b9/2026/day-56/images/task%203.1.JPG)

---
### Task 4: Stable Network Identity
Each StatefulSet pod gets a DNS name: `<pod-name>.<service-name>.<namespace>.svc.cluster.local`
1. Use `nslookup` or `dig` inside a pod to resolve the DNS name of each StatefulSet pod
2. Confirm the IPs match `kubectl get pods -o wide`

![task4](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/5c7aa92597e93f4f504eebca8249155d16e806b9/2026/day-56/images/task%204.JPG)

**Verify:** Does the nslookup IP match the pod IP?
- Yes, the IP returned by nslookup should match the pod IP shown in `kubectl get pods -o wide`
---
### Task 5: Stable Storage — Data Survives Pod Deletion
1. Write unique data to each pod: `kubectl exec web-0 -- sh -c "echo 'Data from web-0' > /usr/share/nginx/html/index.html"`
2. Delete `web-0`: `kubectl delete pod web-0`
3. Wait for it to come back, then check the data — it should still be "Data from web-0"

The new pod reconnected to the same PVC.

**Verify:** Is the data identical after pod recreation?
- Yes, the data should be the same, confirming that the PVC is persistent and attached to the new pod instance.

![task5](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/5c7aa92597e93f4f504eebca8249155d16e806b9/2026/day-56/images/task%205.JPG)

---
### Task 6: Ordered Scaling
1. Scale up to 5: `kubectl scale statefulset web --replicas=5` — pods create in order (web-3, then web-4)

After Scaling 5 

![task6](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/5c7aa92597e93f4f504eebca8249155d16e806b9/2026/day-56/images/taks%206.JPG)


2. Scale down to 3 — pods terminate in reverse order (web-4, then web-3)
3. Check `kubectl get pvc` — all five PVCs still exist. Kubernetes keeps them on scale-down so data is preserved if you scale back up.

**Verify:** After scaling down, how many PVCs exist?
- All 5 PVCs still exist, confirming that Kubernetes retains them for potential future use.

![task6.1](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/5c7aa92597e93f4f504eebca8249155d16e806b9/2026/day-56/images/task%206.1.JPG)

---

### Task 7: Clean Up
1. Delete the StatefulSet and the Headless Service

![task7](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/5c7aa92597e93f4f504eebca8249155d16e806b9/2026/day-56/images/task%207.JPG)

2. Check `kubectl get pvc` — PVCs are still there (safety feature)
3. Delete PVCs manually

![task7.1](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/5c7aa92597e93f4f504eebca8249155d16e806b9/2026/day-56/images/task%207.1.JPG)

**Verify:** Were PVCs auto-deleted with the StatefulSet?
- No, PVCs are not auto-deleted to prevent data loss. You must delete them manually if you want to remove them.
---
## 🎉 Conclusion
StatefulSets are essential for managing stateful applications in Kubernetes. They provide stable network identities, ordered deployment, and persistent storage, making them ideal for databases and other stateful workloads. Understanding how to use StatefulSets effectively is crucial for running reliable stateful applications on Kubernetes.

