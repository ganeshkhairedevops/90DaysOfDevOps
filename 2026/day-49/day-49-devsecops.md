# 🚀 Day 49 – DevSecOps: Securing CI/CD Pipeline

## 📌 What is DevSecOps?
DevSecOps means integrating security directly into the CI/CD pipeline.  
Instead of fixing vulnerabilities after deployment, security checks are automated and executed during development and deployment stages.

---

## 🔍 Security Enhancements Added

### Task 1: Scan Your Docker Image for Vulnerabilities
- Use tools like Trivy or Snyk to scan Docker images for known vulnerabilities.
- Added Trivy scan after Docker build
- Scans for known vulnerabilities (CVEs)
- Pipeline fails if CRITICAL vulnerabilities are found


### Task 2: Enable GitHub's Built-in Secret Scanning
- Detect exposed secrets in code
- GitHub scans for API keys, credentials, and other secrets
- Alerts developers if secrets are accidentally committed

**Enabled in repository settings:**
- Detects secrets (API keys, tokens)
- Push protection blocks commits with secrets

**Difference:**
- Secret scanning → detects after push
- Push protection → blocks before push

**If AWS key is leaked:**
- GitHub detects it
- Sends alert
- May revoke key automatically

**What is the difference between secret scanning and push protection?**
- Secret scanning detects secrets after they are pushed to the repository and sends alerts to developers.
- Push protection blocks commits that contain secrets before they are pushed to the repository, preventing accidental exposure.

**What happens if GitHub detects a leaked AWS key in your repo?**
- GitHub's secret scanning will detect the leaked AWS key and send an alert to the repository administrators.
- If the key is associated with a known service, GitHub may also automatically revoke the key to prevent unauthorized access.
---
### Task 3: Scan Dependencies for Known Vulnerabilities
- Use tools like Dependabot or Snyk to scan project dependencies
- Automatically creates PRs to update vulnerable dependencies
- Regularly checks for new vulnerabilities in dependencies
- Added Dependabot configuration to monitor dependencies


**Does the dependency review show up as a check on your PR?**

Yes

![task3](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/181087a3ccee10cc003faaefbfcf8aca03eb038a/2026/day-49/images/task%203.jpg)

### Task 4: Add Permissions to Your Workflows
- Use least privilege principle
- Define specific permissions for each workflow
- Limit access to secrets and repository contents
