# Day 59 – Helm (Kubernetes Package Manager)

## What is Helm?
Helm is the package manager for Kubernetes. It simplifies deployment by packaging Kubernetes manifests into charts. Helm has three core concepts:
- **Chart**: A package of manifests and templates
- **Release**: A deployed instance of a chart
- **Repository**: A collection of charts


## Installing Helm
- macOS: `brew install helm`
- Linux: `curl ... | bash`
- Windows: `choco install kubernetes-helm`
Verify: `helm version`, `helm env`

## Using Charts
- Add repo: `helm repo add bitnami https://charts.bitnami.com/bitnami`
- Search: `helm search repo nginx`
- Install: `helm install my-nginx bitnami/nginx`
- Customize: `helm install my-nginx-custom bitnami/nginx --set replicaCount=3 --set service.type=NodePort`
- Upgrade: `helm upgrade my-nginx --set replicaCount=5`
- Rollback: `helm rollback my-nginx 1`

## Helm Chart Structure
- `Chart.yaml` – metadata
- `values.yaml` – default configurations
- `templates/` – Kubernetes manifests with Go templating
Example template syntax: `{{ .Values.replicaCount }}`

---

# Challenge Tasks
## Task 1: Install Helm
Installation (depends on OS):
- macOS (Homebrew):
```bash
brew install helm
```
- Linux (curl script):
```bash
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```
- Windows (Chocolatey):
```powershell
choco install kubernetes-helm
```
Verify installation:
```bash
helm version
helm env
```
**Core Concepts:**

- **Chart** — a package of Kubernetes manifest templates
- **Release** — a specific installation of a chart in your cluster
- **Repository** — a collection of charts (like a package repo)

![task1](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/e1a0250564e64736b7885f64dd8180c2c95adf34/2026/day-59/images/task%201.jpg)

**Verify:** What version of Helm is installed?

version.BuildInfo Version:"v3.20.1"

---

## Task 2: Add Repository and Search

1. Add the Bitnami repository:
```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
```
2. Update:
```bash
helm repo update
```
3. Search charts:
```bash
helm search repo nginx
helm search repo bitnami
```

![task2](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/e1a0250564e64736b7885f64dd8180c2c95adf34/2026/day-59/images/task%202.jpg)

**Verify:** How many charts does Bitnami have?

145

![task2.1](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/e1a0250564e64736b7885f64dd8180c2c95adf34/2026/day-59/images/task%202.1.jpg)

---

## Task 3: Install a Chart
1. Install nginx from Bitnami:
```bash
helm install my-nginx bitnami/nginx
```
![task3](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/e1a0250564e64736b7885f64dd8180c2c95adf34/2026/day-59/images/task%203.jpg)

2. Check resources created:
```bash
kubectl get all
```
![task3.1](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/e1a0250564e64736b7885f64dd8180c2c95adf34/2026/day-59/images/task%203.1.jpg)

3. Inspect the release:
```bash
helm list
helm status my-nginx
helm get manifest my-nginx
```
One command replaced writing a Deployment, Service, and ConfigMap by hand.

![task3.3](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/e1a0250564e64736b7885f64dd8180c2c95adf34/2026/day-59/images/task%203.3.jpg)

**Verify:** How many Pods are running? What Service type was created?

- **Pods running:** 1 by default
- **Service type:** LoadBalancer 


---

## Task 4: Customize with Values
1. View default values:
```bash
helm show values bitnami/nginx
```
2. Install with command-line overrides:
```bash
helm install my-nginx-custom bitnami/nginx --set replicaCount=3 --set service.type=NodePort
```
![task4](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/e1a0250564e64736b7885f64dd8180c2c95adf34/2026/day-59/images/task%204.jpg)

3. Create custom-values.yaml:
```yaml
replicaCount: 3
service:
  type: NodePort
resources:
  limits:
    cpu: 500m
    memory: 256Mi
  requests:
    cpu: 250m
    memory: 128Mi
```
4. Install using the values file:
```bash
helm install my-nginx-values -f custom-values.yaml
```
![task4.1](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/e1a0250564e64736b7885f64dd8180c2c95adf34/2026/day-59/images/task%204.1.jpg)

5. Check overrides:
```bash
helm get values my-nginx-values
```
![task4.2](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/e1a0250564e64736b7885f64dd8180c2c95adf34/2026/day-59/images/task%204.2.jpg)

**Verify:** Does the values file release have the correct replicas and service type?
- Replicas: 3
- Service type: NodePort

---

## Task 5: Upgrade and Rollback
1. Upgrade replicas to 5:
```bash
helm upgrade my-nginx bitnami/nginx --set replicaCount=5
```
![task5](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/e1a0250564e64736b7885f64dd8180c2c95adf34/2026/day-59/images/task%205.jpg)

2. Check history:
```bash
helm history my-nginx
```
3. Rollback to revision 1:
```bash
helm rollback my-nginx 1
```
4. Check history again — rollback creates a new revision (3), not overwriting revision 2

**Verify:** How many revisions after the rollback?

**3 revisions** (1 = initial, 2 = upgrade, 3 = rollback).

![task5.1](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/e1a0250564e64736b7885f64dd8180c2c95adf34/2026/day-59/images/task%205.1.jpg)

---
## Task 6: Create Your Own Chart
1. Scaffold chart:
```bash
helm create my-app
```
![task6](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/e1a0250564e64736b7885f64dd8180c2c95adf34/2026/day-59/images/task%206.jpg)


2. Explore the directory:

- Chart.yaml – metadata (name, version, description)
- values.yaml – default configuration
- templates/deployment.yaml – uses Go templating:
3. Look at the Go template syntax in templates: {{ .Values.replicaCount }}, {{ .Chart.Name }}
4. Edit values.yaml — set replicaCount to 3 and image to nginx:1.25
```yaml
replicaCount: 3
image:
  repository: nginx
  tag: 1.25
```
![task6.1](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/e1a0250564e64736b7885f64dd8180c2c95adf34/2026/day-59/images/task%206.1.jpg)

5. Validate:
```bash
helm lint my-app
```
6. Preview:
```bash
helm template my-release ./my-app
```
7. Install:
```bash
helm install my-release ./my-app
```
![task6.2](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/e1a0250564e64736b7885f64dd8180c2c95adf34/2026/day-59/images/task%206.2.jpg)

8. Upgrade: 
```bash
helm upgrade my-release ./my-app --set replicaCount=5
```

![task6.3](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/e1a0250564e64736b7885f64dd8180c2c95adf34/2026/day-59/images/task%206.3.jpg)

**Verify:** After installing, 3 replicas? After upgrading, 5?

- Initial install: 3 replicas
- After upgrade: 5 replicas

---

## Task 7: Clean Up
1. Uninstall all releases: 
```bash
helm uninstall my-nginx
helm uninstall my-nginx-custom
helm uninstall nginx-file
helm uninstall my-release
```
2. Remove chart directory and values file
```bash
rm -rf my-app custom-values.yaml
```
3. Use --keep-history if you want to retain release history for auditing

If you want to retain release history for auditing:
```bash
helm uninstall my-nginx --keep-history
```
![task7](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/e1a0250564e64736b7885f64dd8180c2c95adf34/2026/day-59/images/task%207.jpg)

**Verify:** Does helm list show zero releases?

```bash
helm list
```
Yes, helm list shows zero releases, confirming that all Helm releases have been successfully uninstalled.