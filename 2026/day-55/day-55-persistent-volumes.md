# Day 55 – Persistent Volumes (PV) and Persistent Volume Claims (PVC)
Explore Persistent Volumes (PV) and Persistent Volume Claims (PVC) in Kubernetes. These concepts are crucial for managing storage in a Kubernetes cluster, allowing applications to persist data even when pods are rescheduled or restarted.

## 📦 Why Containers Need Persistent Storage
Containers are ephemeral by nature, meaning that any data stored within a container will be lost if the container is stopped or deleted. This poses a challenge for applications that require data persistence, such as databases or content management systems. Persistent storage allows these applications to retain their data across pod restarts and rescheduling.

This is a problem for:
- Databases
- Logs
- Application state

Solution: Kubernetes provides **Persistent Volumes (PV)** and **Persistent Volume Claims (PVC)**

## What PVs and PVCs are and how they relate
- **Persistent Volume (PV)**: A PV is a piece of storage in the cluster that has been provisioned by an administrator or dynamically provisioned using Storage Classes. It is a resource in the cluster just like a node is a cluster resource. PVs are independent of the lifecycle of pods and can be reused across different pods.
- **Persistent Volume Claim (PVC)**: A PVC is a request for storage by a user. It specifies the desired size and access modes for the storage. When a PVC is created, Kubernetes will look for a PV that matches the claim's requirements and bind them together. Once bound, the PVC can be used by pods to access the storage.

## Static vs dynamic provisioning
- **Static Provisioning**: An administrator manually creates PVs and makes them available for use. Users then create PVCs that match the specifications of the available PVs.
- **Dynamic Provisioning**: Kubernetes can automatically provision PVs based on Storage Classes when a PVC is created. This eliminates the need for administrators to pre-create PVs and allows for more flexible storage management.

## Access modes and reclaim policies
- **Access Modes**: PVs can specify access modes such as ReadWriteOnce (RWO), ReadOnlyMany (ROX), and ReadWriteMany (RWX) to define how the storage can be accessed by pods.
- **Reclaim Policies**: PVs can have reclaim policies such as Retain, Recycle, or Delete that determine what happens to the PV when the PVC is deleted.
---

# Challenge Tasks
## Task 1: See the Problem — Data Lost on Pod Deletion
1. Write a Pod manifest that uses an `emptyDir` volume and writes a timestamped message to `/data/message.txt`
2. Apply it, verify the data exists with `kubectl exec`
3. Delete the Pod, recreate it, check the file again — the old message is gone

Create a file `emptydir-pod.yaml:`
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: emptydir-demo
spec:
  containers:
  - name: app
    image: busybox
    command: ["/bin/sh", "-c"]
    args:
      - |
        date > /data/message.txt
        sleep 3600
    volumeMounts:
    - name: temp-storage
      mountPath: /data
  volumes:
  - name: temp-storage
    emptyDir: {}
```
Apply the Pod
```bash
kubectl apply -f emptydir-pod.yaml
kubectl get pods
```
Verify the data
```bash
kubectl exec emptydir-demo -- cat /data/message.txt
```
![task1](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/fe2d779647322882d6023ec044bfbf67f5649b93/2026/day-55/images/task%201.JPG)

Delete and recreate the Pod
```bash
kubectl delete pod emptydir-demo
kubectl apply -f emptydir-pod.yaml
```
Check the file again
```bash
kubectl exec emptydir-demo -- cat /data/message.txt
```

![task1.2](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/fe2d779647322882d6023ec044bfbf67f5649b93/2026/day-55/images/task%201.1.JPG)

**Verify:** Is the timestamp the same or different after recreation?
- Yes, The timestamp is DIFFERENT
- `emptyDir` is ephemeral storage
- It is created when the Pod starts
- It is deleted permanently when the Pod is deleted

So when you recreate the Pod:
- A fresh empty volume is created
- The file is written again with a new timestamp

---

## Task 2: Create a PersistentVolume (Static Provisioning)
1. Write a PV manifest with `capacity: 1Gi`, `accessModes: ReadWriteOnce`, `persistentVolumeReclaimPolicy: Retain`, and `hostPath` pointing to `/tmp/k8s-pv-data`
2. Apply it and check `kubectl get pv` — status should be `Available`

Access modes to know:
- `ReadWriteOnce (RWO)` — read-write by a single node
- `ReadOnlyMany (ROX)` — read-only by many nodes
- `ReadWriteMany (RWX)` — read-write by many nodes

`hostPath` is fine for learning, not for production.
Create a file `pv.yaml:`
```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: my-pv
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  hostPath:
    path: /tmp/k8s-pv-data
```
Apply the PV and verify
```bash
kubectl apply -f pv.yaml
kubectl get pv
```
![task2](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/fe2d779647322882d6023ec044bfbf67f5649b93/2026/day-55/images/task%202.JPG)

**Verify:** What is the STATUS of the PV?
- `Available` means it is not yet bound to any PVC.

---
## Task 3: Create a PersistentVolumeClaim (PVC) and Bind to PV
1. Write a PVC manifest requesting `500Mi` of storage with `ReadWriteOnce` access
2. Apply it and check both `kubectl get pvc` and `kubectl get pv`
3. Both should show `Bound` — Kubernetes matched them by capacity and access mode

Create a file `pvc.yaml:`
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-pvc
spec:
  storageClassName: ""
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 500Mi
```
Apply the PVC and verify
```bash
kubectl apply -f pvc.yaml
kubectl get pvc
kubectl get pv
```
![task3](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/fe2d779647322882d6023ec044bfbf67f5649b93/2026/day-55/images/task%203.JPG)

**Verify:** What does the VOLUME column in kubectl get pvc show?
- It shows `my-pv`, indicating that the PVC is bound to the PV named `my-pv`.

---

## Task 4: Use the PVC in a Pod — Data That Survives
1. Write a Pod manifest that mounts the PVC at `/data` using `persistentVolumeClaim.claimName`
2. Write data to `/data/message.txt`, then delete and recreate the Pod
3. Check the file — it should contain data from both Pods

Create a file `pvc-pod.yaml:`
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: pvc-pod
spec:
  containers:
  - name: writer
    image: busybox
    command: ["/bin/sh", "-c"]
    args:
      - echo "First run: $(date)" >> /data/message.txt && sleep 3600
    volumeMounts:
    - name: data-volume
      mountPath: /data
  volumes:
  - name: data-volume
    persistentVolumeClaim:
      claimName: my-pvc
```
Apply the Pod and verify
```bash
kubectl apply -f pvc-pod.yaml
kubectl exec pvc-pod -- cat /data/message.txt
```
![task4](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/fe2d779647322882d6023ec044bfbf67f5649b93/2026/day-55/images/task%204.JPG)

Delete and recreate the Pod
```bash
kubectl delete pod pvc-pod
kubectl apply -f pvc-pod.yaml
```
Check the file again
```bash
kubectl exec pvc-pod -- cat /data/message.txt
```
![task4.1](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/fe2d779647322882d6023ec044bfbf67f5649b93/2026/day-55/images/task%204.1.JPG)

**Verify:** Does the file contain messages from both runs?
- Yes, the file contains messages from both runs, demonstrating that the data persisted across Pod deletions and recreations thanks to the PVC.
---
## Task 5: StorageClasses and Dynamic Provisioning
1. Run `kubectl get storageclass` and `kubectl describe storageclass`
2. Note the provisioner, reclaim policy, and volume binding mode
- Provisioner → e.g. rancher.io/local-path
- Reclaim Policy → Delete (dynamic volumes get deleted automatically)
- Volume Binding Mode → WaitForFirstConsumer

---
- Volume Binding Mode:
- Immediate → volume created instantly
- WaitForFirstConsumer → created when Pod is scheduled

![task5](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/fe2d779647322882d6023ec044bfbf67f5649b93/2026/day-55/images/task%205.JPG)

**Verify:** What is the default StorageClass in your cluster?
- standard

---
## Task 6: Dynamic Provisioning
1. Write a PVC manifest that includes storageClassName: standard (or your cluster's default)

2. Apply it — a PV should appear automatically in kubectl get pv
3. Use this PVC in a Pod, write data, verify it works

Create a file `dynamic-pvc.yaml:`
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: dynamic-pvc
spec:
  storageClassName: standard   # triggers dynamic provisioning
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 500Mi
```
Apply the PVC and verify
```bash
kubectl apply -f dynamic-pvc.yaml
kubectl get pvc
kubectl get pv
```

Use PVC in a Pod
Create `dynamic-pod.yaml:`
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: dynamic-pod
spec:
  containers:
  - name: writer
    image: busybox
    command: ["/bin/sh", "-c"]
    args:
      - 'echo "Dynamic PV test: $(date)" >> /data/message.txt && sleep 3600'
    volumeMounts:
    - name: data-volume
      mountPath: /data
  volumes:
  - name: data-volume
    persistentVolumeClaim:
      claimName: dynamic-pvc
```
Apply the Pod and verify
```bash
kubectl apply -f dynamic-pod.yaml
kubectl get pvc
kubectl exec dynamic-pod -- cat /data/message.txt
```

![task6](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/fe2d779647322882d6023ec044bfbf67f5649b93/2026/day-55/images/task%206.1.JPG)

Verify: How many PVs exist now? Which was manual, which was dynamic?
- There should be 2 PVs: `my-pv` (manual) and a new one created for `dynamic-pvc` (dynamic).
- PV created automatically
- No manual PV needed
---
## Task 7: Clean Up
1. Delete all pods first
```bash
kubectl delete pod --all
```
2. Delete PVCs — check `kubectl get pv` to see what happened
```bash
kubectl delete pvc --all
kubectl get pv
```
3. The dynamic PV is gone (Delete reclaim policy). The manual PV shows `Released` (Retain policy).
```bash
kubectl delete pv my-pv
kubectl get pv
```
4. Delete the remaining PV manually
```bash
kubectl delete pv --all
```
![task7](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/fe2d779647322882d6023ec044bfbf67f5649b93/2026/day-55/images/task%207.JPG)
---
**Verify:** Which PV was auto-deleted and which was retained? Why?
- The dynamic PV was auto-deleted because it had a `Delete` reclaim policy, meaning it gets deleted when the PVC is deleted.
- The manual PV was retained because it had a `Retain` reclaim policy, meaning it remains even after the PVC is deleted and must be manually cleaned up.




