# Day 60 – Capstone: Deploy WordPress + MySQL on Kubernetes

## 📦 Project Overview

This capstone project combines all core Kubernetes concepts by deploying a **WordPress + MySQL application** with:

- Persistent storage
- Self-healing
- Configuration management
- Autoscaling

## 🏗 Architecture

This deployment consists of:

- Namespace: capstone
- MySQL
    - Secret for credentials
    - Headless Service for stable network identity
    - StatefulSet with persistent storage
- WordPress
    - ConfigMap for DB connection
    - Deployment with 2 replicas
    - NodePort Service for external access
- Storage
    - Persistent Volume Claim via volumeClaimTemplates
- Autoscaling
    - Horizontal Pod Autoscaler

## Flow

WordPress Pods → MySQL Headless Service → MySQL StatefulSet Pod → Persistent Volume

---

## Challenge Tasks
### Task 1: Create the Namespace (Day 52)
1. Create a `capstone` namespace

Create a file `namespace.yaml`
```bash
apiVersion: v1
kind: Namespace
metadata:
  name: capstone
```
2. Set it as your default: `kubectl config set-context --current --namespace=capstone`

![task1](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/d67675a3f73c7af74825ee6f96330b1fdc251de6/2026/day-60/images/task%201.JPG)

---

### Task 2: Deploy MySQL (Days 54-56)
1. Create a Secret with `MYSQL_ROOT_PASSWORD`, `MYSQL_DATABASE`, `MYSQL_USER`, and `MYSQL_PASSWORD` using `stringData`

Create a `mysql-secret.yaml`
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: mysql-secret
type: Opaque
stringData:
  MYSQL_ROOT_PASSWORD: mysecurepass
  MYSQL_DATABASE: wordpress
  MYSQL_USER: wpuser
  MYSQL_PASSWORD: mysecurepass
```
2. Create a Headless Service (`clusterIP: None`) for MySQL on port 3306

Create a file `mysql-headless-svc.yaml`
```yaml
apiVersion: v1
kind: Service
metadata:
  name: mysql-svc
  labels:
    app: mysql
spec:
  ports:
    - name: mysql
      port: 3306
  clusterIP: None
  selector:
    app: mysql
```
3. Create a StatefulSet for MySQL with:
   - Image: `mysql:8.0`
   - `envFrom` referencing the Secret
   - Resource requests (cpu: 250m, memory: 512Mi) and limits (cpu: 500m, memory: 1Gi)
   - A `volumeClaimTemplates` section requesting 1Gi of storage, mounted at `/var/lib/mysql`
Create a file `mysql-statefulset.yaml`
```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: mysql
spec:
  selector:
    matchLabels:
      app: mysql
  serviceName: mysql-svc
  replicas: 1
  template:
    metadata:
      labels:
        app: mysql
    spec:
      containers:
        - name: mysql
          image: mysql:8.0
          envFrom:
            - secretRef:
                name: mysql-secret
          ports:
            - name: mysql
              containerPort: 3306
          resources:
            requests:
              cpu: "250m"
              memory: "512Mi"
            limits:
              cpu: "500m"
              memory: "1Gi"
          volumeMounts:
            - name: mysql-data
              mountPath: /var/lib/mysql
  volumeClaimTemplates:
    - metadata:
        name: mysql-data
      spec:
        accessModes: ["ReadWriteOnce"]
        resources:
          requests:
            storage: 1Gi
```
4. Verify MySQL works: `kubectl exec -it mysql-0 -- mysql -u <user> -p<password> -e "SHOW DATABASES;"`
```bash
kubectl exec -it mysql-0 -- mysql -u wpuser -p -e "SHOW DATABASES;"
```


**Verify:** Can you see the `wordpress` database?

- YES

![task2](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/d67675a3f73c7af74825ee6f96330b1fdc251de6/2026/day-60/images/task%202.JPG)

---

### Task 3: Deploy WordPress (Days 52, 54, 57)
1. Create a ConfigMap with `WORDPRESS_DB_HOST` set to `mysql-0.mysql.capstone.svc.cluster.local:3306` and `WORDPRESS_DB_NAME`

Create a file `configmap.yaml`
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: wordpress-config
data:
  WORDPRESS_DB_HOST: mysql-0.mysql-svc.capstone.svc.cluster.local:3306
  WORDPRESS_DB_NAME: wordpress
```
2. Create a Deployment with 2 replicas using `wordpress:latest` that:
   - Uses `envFrom` for the ConfigMap
   - Uses `secretKeyRef` for `WORDPRESS_DB_USER` and `WORDPRESS_DB_PASSWORD` from the MySQL Secret
   - Has resource requests and limits
   - Has a liveness probe and readiness probe on `/wp-login.php` port 80

Create a file `wordpress-deployment.yaml`
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: wordpress
  labels:
    app: wordpress
spec:
  replicas: 2
  selector:
    matchLabels:
      app: wordpress
  template:
    metadata:
      labels:
        app: wordpress
    spec:
      containers:
        - name: wordpress
          image: wordpress:latest
          envFrom:
            - configMapRef:
                name: wordpress-config
          env:
            - name: WORDPRESS_DB_USER
              valueFrom:
                secretKeyRef:
                  name: mysql-secret
                  key: MYSQL_USER
            - name: WORDPRESS_DB_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: mysql-secret
                  key: MYSQL_PASSWORD
          ports:
            - containerPort: 80
          resources:
            requests:
              cpu: "200m"
              memory: "512Mi"
            limits:
              cpu: "500m"
              memory: "1Gi"
          livenessProbe:
            httpGet:
              path: /wp-login.php
              port: 80
            initialDelaySeconds: 10
            periodSeconds: 5
            timeoutSeconds: 3
          readinessProbe:
            httpGet:
              path: /wp-login.php
              port: 80
            initialDelaySeconds: 10
            periodSeconds: 5
            timeoutSeconds: 3
```
3. Wait until both pods show `1/1 Running`

**Verify:** Are both WordPress pods running and ready?

- YES

![task3](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/d67675a3f73c7af74825ee6f96330b1fdc251de6/2026/day-60/images/task%203.JPG)

---

### Task 4: Expose WordPress (Day 53)
1. Create a NodePort Service on port 30080 targeting the WordPress pods

Create a file `wordpress-svc.yaml`
```yaml
apiVersion: v1
kind: Service
metadata:
  name: wordpress-svc
spec:
  selector:
    app: wordpress
  type: NodePort
  ports:
    - port: 80
      targetPort: 80
      nodePort: 30080
```
![task4](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/d67675a3f73c7af74825ee6f96330b1fdc251de6/2026/day-60/images/task%204.JPG)

2. Access WordPress in your browser:
   - Minikube: `minikube service wordpress -n capstone`
   - Kind: `sudo kubectl port-forward svc/wordpress-svc 8080:80 -n capstone &`
3. Complete the setup wizard and create a blog post

![task4.2](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/d67675a3f73c7af74825ee6f96330b1fdc251de6/2026/day-60/images/task%204.1.JPG)

**Verify:** Can you see the WordPress setup page?

- YES

![task4.1](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/d67675a3f73c7af74825ee6f96330b1fdc251de6/2026/day-60/images/task%204.2.JPG)

---

### Task 5: Test Self-Healing and Persistence
1. Delete a WordPress pod — watch the Deployment recreate it within seconds. Refresh the site.
```bash
kubectl delete pod wordpress-79c77cc6d9-g4d48
```
![task5](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/d67675a3f73c7af74825ee6f96330b1fdc251de6/2026/day-60/images/task%205.JPG)

![task5.1](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/d67675a3f73c7af74825ee6f96330b1fdc251de6/2026/day-60/images/task%205.1.JPG)

2. Delete the MySQL pod: `kubectl delete pod mysql-0 -n capstone` — watch the StatefulSet recreate it
![task5.2](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/d67675a3f73c7af74825ee6f96330b1fdc251de6/2026/day-60/images/task%205.2.JPG)

![task5.3](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/d67675a3f73c7af74825ee6f96330b1fdc251de6/2026/day-60/images/task%205.3.JPG)

3. After MySQL recovers, refresh WordPress — your blog post should still be there

**Verify:** After deleting both pods, is your blog post still there?
- YES


---
### Task 6: Set Up HPA (Day 58)
1. Write an HPA manifest targeting the WordPress Deployment with CPU at 50%, min 2, max 10 replicas

Create a file `wordpress-hpa.yaml`
```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: wordpress-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: wordpress
  minReplicas: 2
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
      stabilizationWindowSeconds: 0
      policies:
        - type: Percent
          value: 100
          periodSeconds: 15
    scaleDown:
      stabilizationWindowSeconds: 300
      policies:
        - type: Percent
          value: 100
          periodSeconds: 15
```

2. Apply and check: 
```bash
kubectl get hpa -n capstone
```
3. Run 
```bash
kubectl get all -n capstone
```

**Verify:** Does the HPA show correct min/max and target?
- YES

![task6](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/d67675a3f73c7af74825ee6f96330b1fdc251de6/2026/day-60/images/task%206.JPG)

---

### Task 7: (Bonus) Compare with Helm (Day 59)
1. Install WordPress using `helm install wp-helm bitnami/wordpress` in a separate namespace

Create a namespace
```bash
kubectl create namespace helm-wp
```
Install Wordpress:
```bash
helm install wp-helm bitnami/wordpress -n helm-wp
```
![task7](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/d67675a3f73c7af74825ee6f96330b1fdc251de6/2026/day-60/images/task%207.JPG)

2. Compare: how many resources did each approach create? Which gives more control?

**Inspect Resources**
```bash
kubectl get all -n helm-wp
```
**capstone**

![task7.1](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/d67675a3f73c7af74825ee6f96330b1fdc251de6/2026/day-60/images/task%207.1.JPG)

**helm-wp**
![task7.2](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/d67675a3f73c7af74825ee6f96330b1fdc251de6/2026/day-60/images/task%207.2.JPG)

- Count
```bash
kubectl get all -n helm-wp | wc -l
```
**capstone**

![task7.3](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/d67675a3f73c7af74825ee6f96330b1fdc251de6/2026/day-60/images/task%207.3.JPG)

## Comparison: Manual vs Helm
### Your Manual Deployment (Capstone)

You explicitly created:

- Namespace
- Secret
- ConfigMap
- Headless Service
- StatefulSet (MySQL)
- PVC (via template)
- Deployment (WordPress)
- NodePort Service
- HPA

 ~8–10 core resources (very intentional)

### Helm Deployment (Bitnami Chart)

Helm creates **more resources automatically,** typically:

- WordPress Deployment
- MariaDB StatefulSet (instead of MySQL)
- Multiple Secrets (DB + app credentials)
- ConfigMaps
- Services (internal + external)
- PVCs
- ServiceAccounts
- Possibly NetworkPolicies

 ~15–25 resources depending on values


3. Clean up the Helm deployment
```bash
helm uninstall wp-helm -n helm-wp
kubectl delete namespace helm-wp
```
![task7.4](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/d67675a3f73c7af74825ee6f96330b1fdc251de6/2026/day-60/images/task%207.4.JPG)

---

### Task 8: Clean Up and Reflect
1. Take a final look: 
```bash
kubectl get all -n capstone`
```
2. Count the concepts you used: Namespace, Secret, ConfigMap, PVC, StatefulSet, Headless Service, Deployment, NodePort Service, Resource Limits, Probes, HPA, Helm — twelve concepts in one deployment
3. Delete the namespace: 
```bash
kubectl delete namespace capstone
```
4. Reset default: 
```bash
kubectl config set-context --current --namespace=default`
```

**Verify:** Did deleting the namespace remove everything?
- YES

![task8](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/d67675a3f73c7af74825ee6f96330b1fdc251de6/2026/day-60/images/task%208.JPG)

---