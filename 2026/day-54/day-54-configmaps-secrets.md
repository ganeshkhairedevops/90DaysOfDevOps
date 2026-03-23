# Day 54 – Kubernetes ConfigMaps and Secrets
## Overview
Today, we explored Kubernetes ConfigMaps and Secrets, which are essential for managing configuration data and sensitive information in a Kubernetes cluster.

## 📦 What are ConfigMaps?
ConfigMaps allow you to decouple configuration artifacts from image content to keep containerized applications portable. They can be used to store non-sensitive configuration data in key-value pairs.

ConfigMaps are used to store **non-sensitive configuration data** in key-value format.

### 🔹 Examples:
- App environment (dev, prod)
- Feature flags
- Application ports

## 🔐 What are Secrets?
Secrets are similar to ConfigMaps but are designed to store sensitive information such as **passwords, OAuth tokens, and SSH keys.** They ensure that sensitive data is stored securely and can be accessed by applications without exposing it in the code.

Secrets are used to store **sensitive data** such as:
- Database credentials
- API keys
- Tokens

## ⚖️ ConfigMaps vs Secrets

| Feature        | ConfigMap            | Secret              |
|---------------|---------------------|---------------------|
| Data type     | Non-sensitive        | Sensitive           |
| Storage       | Plain text           | Base64 encoded      |
| Use case      | App config           | Credentials         |

---
## The difference between environment variables and volume mounts
Both environment variables and volume mounts are methods to inject configuration data into containers, but they serve different purposes.
### Environment Variables
- Used to pass configuration data as key-value pairs directly into the container.
- Suitable for small amounts of data, such as database credentials or API keys.
### Volume Mounts
- Used to mount files from a ConfigMap or Secret into the container's filesystem.
- Suitable for larger configuration data or when the application expects configuration files.
### When to use each:
- Use environment variables for simple key-value pairs that can be easily injected into the container.
- Use volume mounts when the application requires configuration files or when dealing with larger sets of configuration data.

## Key Differences
| Feature |	Environment Variables |	Volume Mounts |
|---------|-----------------------|---------------|
| Format |	Key-value |	Files |
|Access	| $VAR_NAME |	File path |
|Auto update | ❌ No |	✅ Yes |
|Best for	| Simple configs	| Complex configs |
|Restart required	| ✅ Yes	| ❌ No |


---

## Why base64 is encoding, not encryption
Base64 encoding is a method of converting binary data into an ASCII string format. It is not a form of encryption, as it does not provide any security or confidentiality. Instead, it simply transforms the data into a format that can be easily transmitted and stored.
### Key Points:
- Base64 encoding is reversible, meaning that anyone can decode the encoded data back to its original form.
- It does not provide any security measures, such as encryption algorithms or keys.
- Base64 is often used to encode data for transmission over media that are designed to deal with textual data, such as email or URLs.

## What Real Encryption Looks Like

| Feature	| Base64 	| Encryption |
|-----------|-----------|-------------|
| Uses key	| ❌ No	| ✅ Yes |
| Secure	| ❌ No	| ✅ Yes |
| Reversible	| ✅ Easy	| ❌ Hard (without key) |
| Purpose	| Encoding	| Security |

---

## How ConfigMap updates propagate to volumes but not env vars
When a ConfigMap is updated, the changes are automatically reflected in any volume mounts that reference that ConfigMap. This is because the volume mount directly references the ConfigMap, allowing Kubernetes to update the contents of the mounted files in real-time.

On the other hand, environment variables are set at the time of container creation and do not automatically update when the ConfigMap changes. To see the updated values in environment variables, you would need to restart the pods that use those environment variables.

### 1. Volume Mounts → ✅ Auto Update

When a ConfigMap is mounted as a volume, Kubernetes:

- Stores data as files inside the container
- Continuously watches for changes
- Updates the mounted files automatically

### 2. Environment Variables → ❌ No Update

When ConfigMap is used as environment variables:

- Values are injected only once at pod startup
- Stored in process environment
- Kubernetes does NOT update them later

### ⚖️ Key Difference
| Feature | Volume Mounts | Environment Variables |
|---------|---------------|-----------------------|
| Update automatically | ✅ Yes | ❌ No |
| Requires pod restart | ❌ No | ✅ Yes |
| Data type | Files | Key-value |

---

## Challenge Tasks

### Task 1: Create a ConfigMap from Literals
1. Use `kubectl create configmap` with `--from-literal` to create a ConfigMap called `app-config` with keys `APP_ENV=production`, `APP_DEBUG=false`, and `APP_PORT=8080`
2. Inspect it with `kubectl describe configmap app-config` and `kubectl get configmap app-config -o yaml`
3. Notice the data is stored as plain text — no encoding, no encryption

```bash
kubectl create configmap app-config \
  --from-literal=APP_ENV=production \
  --from-literal=APP_DEBUG=false \
  --from-literal=APP_PORT=8080
```
**Inspect**
```bash
kubectl describe configmap app-config
kubectl get configmap app-config -o yaml
```
![task1](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/c8247a081b0b72a61911facc491f908df138a850/2026/day-54/images/task%201.JPG)

**Verify:** Can you see all three key-value pairs?
- All three keys are present
- Values are stored in plain text
- Nothing is hidden, encoded, or encrypted
---
### Task 2: Create a ConfigMap from a File
1. Create the Nginx config file

Create a file named `default.conf:`
```nginx
server {
    listen 80;

    location /health {
        return 200 'healthy';
        add_header Content-Type text/plain;
    }

    location / {
        return 404;
    }
}
```
Save it locally

2. Create a ConfigMap from the file:
```bash
kubectl create configmap nginx-config --from-file=default.conf=default.conf
```
![task2](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/c8247a081b0b72a61911facc491f908df138a850/2026/day-54/images/task%202.JPG)

**Verify:** Does kubectl get configmap nginx-config -o yaml show the file contents?
```bash
kubectl get configmap nginx-config -o yaml
```
- Yes, the file contents are visible in the `data` section
- The key is `default.conf` and the value is the entire file content
---
### Task 3: Use ConfigMaps in a Pod
Pod using envFrom
1. Create a Pod that uses the `config-env-pod` ConfigMap as environment variables:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: config-env-pod
spec:
  containers:
  - name: busybox
    image: busybox
    command: ["sh", "-c", "env && sleep 3600"]
    envFrom:
    - configMapRef:
        name: app-config
```
Apply the manifest:
```bash
kubectl apply -f config-env-pod.yaml
kubectl logs config-env-pod
```
![task3](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/c8247a081b0b72a61911facc491f908df138a850/2026/day-54/images/task%203.JPG)

Expected output:
```bash
APP_ENV=production
APP_DEBUG=false
APP_PORT=8080
```
---
2. Pod mounting ConfigMap as a volume (nginx-config)
Create a Pod that mounts the `nginx-config` ConfigMap as a volume:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-config-pod
spec:
  containers:
  - name: nginx
    image: nginx
    volumeMounts:
    - name: config-volume
      mountPath: /etc/nginx/conf.d
  volumes:
  - name: config-volume
    configMap:
      name: nginx-config
```
Apply the manifest:
```bash
kubectl apply -f volume-demo.yaml
```
Test the /health endpoint

Once the pod is running:
```bash
kubectl exec nginx-config-pod -- curl -s http://localhost/health
```

![task3-2](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/c8247a081b0b72a61911facc491f908df138a850/2026/day-54/images/task%203.1.jpg)

---
### Task 4: Create a Secret
1. Create a Secret named `db-credentials
```bash
kubectl create secret generic db-credentials \
  --from-literal=DB_USER=admin \
  --from-literal=DB_PASSWORD=s3cureP@ssw0rd
```
2. Inspect the Secret:
```bash
kubectl describe secret db-credentials
kubectl get secret db-credentials -o yaml
```
3. Decode a value
```bash
echo 'czNjdXJlUEBzc3cwcmQ=' | base64 --decode
```
Output
```bash
s3cureP@ssw0rd
```
![task4](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/c8247a081b0b72a61911facc491f908df138a850/2026/day-54/images/task%204.jpg)

**Verify:** Can you decode the password back to plaintext?
- Yes, using base64 decoding reveals the original password

---
### Task 5: Use Secrets in a Pod
1. Create a file `secret-pod.yaml` with the following content:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: secret-pod
spec:
  containers:
  - name: busybox
    image: busybox
    command: ["sh", "-c", "env && sleep 3600"]
    env:
    - name: DB_USER
      valueFrom:
        secretKeyRef:
          name: db-credentials
          key: DB_USER
    volumeMounts:
    - name: secret-volume
      mountPath: /etc/db-credentials
      readOnly: true
  volumes:
  - name: secret-volume
    secret:
      secretName: db-credentials
```
**Explanation:**

1. env → Injects DB_USER directly as an environment variable from the Secret.
2. volumeMounts → Mounts all Secret keys as files under /etc/db-credentials (read-only).
3. volumes → References the Secret to populate the volume

Apply the manifest:
```bash
kubectl apply -f secret-pod.yaml
kubectl logs secret-pod
```
![task5](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/c8247a081b0b72a61911facc491f908df138a850/2026/day-54/images/task%205.jpg)

Verify Environment Variable
```bash
kubectl exec -it secret-pod -- printenv DB_USER
```

**Verify:**

Are the mounted file values plaintext or base64?
- The mounted file values are plaintext, as Kubernetes automatically decodes the Secret data when mounting it as a volume. You can read the contents of the files to see the original values without needing to decode them manually.

Verify Mounted Files
```bash
kubectl exec -it secret-pod -- ls /etc/db-credentials
kubectl exec -it secret-pod -- cat /etc/db-credentials/DB_PASSWORD
```
![task5.1](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/c8247a081b0b72a61911facc491f908df138a850/2026/day-54/images/task%205.1.jpg)

---

### Task 6: Update a ConfigMap and Observe Propagation
1. Create a ConfigMap `live-config` with a key `message=hello`
```bash
kubectl create configmap live-config --from-literal=message=hello
```
Check
```bash
kubectl describe configmap live-config
```
![task6](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/c8247a081b0b72a61911facc491f908df138a850/2026/day-54/images/task%206.JPG)

2. Write a Pod that mounts this ConfigMap as a volume and reads the file in a loop every 5 seconds

Create `configmap-pod.yaml:`
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: configmap-demo
spec:
  containers:
    - name: app
      image: busybox
      command: ["/bin/sh", "-c"]
      args:
        - |
          while true; do
            echo "------"
            cat /etc/config/message
            sleep 5
          done
      volumeMounts:
        - name: config-vol
          mountPath: /etc/config
  volumes:
    - name: config-vol
      configMap:
        name: live-config
```
Apply the manifest:
```bash
kubectl apply -f configmap-pod.yaml
```
Check the logs of the pod to see the message
```bash
kubectl logs configmap-demo
or
kubectl logs -f configmap-demo
```
Expected output:
```bash
hello
hello
hello
```
![task6.1](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/c8247a081b0b72a61911facc491f908df138a850/2026/day-54/images/task%206.1.JPG)

3. Update the ConfigMap with a new message
```bash
kubectl patch configmap live-config --type merge -p '{"data":{"message":"world"}}'
```
![task6.2](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/c8247a081b0b72a61911facc491f908df138a850/2026/day-54/images/task%206.2.JPG)

Wait 30-60 seconds — the volume-mounted value updates automatically

Observe automatic update
Check the logs again:
```bash
kubectl logs configmap-demo
or
kubectl logs -f configmap-demo
```
Expected output:
```bash
world
world
world
```
![task6.3](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/c8247a081b0b72a61911facc491f908df138a850/2026/day-54/images/task%206.3.JPG)

**Verify:** Did the volume-mounted value change without a pod restart?
- Yes, the logs show the updated message "world" without restarting the pod, demonstrating that volume mounts automatically reflect ConfigMap updates.
---
### Task 7: Clean Up
Delete all pods, ConfigMaps, and Secrets you created.
```bash
kubectl delete pod config-env-pod nginx-config-pod secret-pod configmap-demo
kubectl delete configmap app-config nginx-config live-config
kubectl delete secret db-credentials
```
Verify Cleanup
```bash
kubectl get pods
kubectl get configmaps
kubectl get secrets
```
![task7](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/c8247a081b0b72a61911facc491f908df138a850/2026/day-54/images/task%207.JPG)

---
## Conclusion
Today, we learned how to use Kubernetes ConfigMaps and Secrets to manage configuration data and sensitive information in our applications. We saw how ConfigMaps can be updated in real-time when mounted as volumes, while environment variables require a pod restart to reflect changes. We also explored the difference between encoding and encryption, and how to securely manage sensitive data using Secrets.
