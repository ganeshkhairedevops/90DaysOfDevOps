# Day 08 – Cloud Server Setup: Docker, Nginx & Web Deployment

Today I deployed a real web server on the cloud and accessed it publicly.
This task helped me understand cloud servers, SSH access, service deployment,
security groups, and basic log handling.

---

## Part 1: Launch Cloud Instance & SSH Access

### Create Cloud Instance
- Launched Ubuntu cloud server
- Generated SSH key
- Assigned public IP

### Connect via SSH
ssh -i "nginx.pem" ubuntu@ec2-3-93-68-102.compute-1.amazonaws.com

Screenshot: ssh-connection
![ssh-connection](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/c6cc203e8d53a83b867da3e2a201ecd2f09a4933/2026/day-08/ssh-connection.jpg)

---

## Part 2: Install Docker & Nginx

sudo apt update && sudo apt upgrade -y

sudo apt install docker.io -y
sudo systemctl start docker
sudo systemctl enable docker

sudo apt install nginx -y
systemctl status nginx

---

## Part 3: Security Group Configuration

- Allowed ports 22 and 80
- Accessed http://3.93.68.102 in browser

Screenshot: nginx-webpage
![nginx-webpage](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/2f25c87bce7dcbc460f368ebe0f77a9983672ecc/2026/day-08/nginx-webpage.jpg)
---

## Part 4: Extract Nginx Logs

sudo tail -n 50 /var/log/nginx/access.log
sudo cat /var/log/nginx/access.log > nginx-logs.txt

scp -i nginx.pem ubuntu@3.93.68.102:~/nginx-logs.txt .

Link:
![nginx-logs](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/2f25c87bce7dcbc460f368ebe0f77a9983672ecc/2026/day-08/nginx-logs.txt)
---

## Commands Used
ssh, apt, systemctl, docker, nginx, tail, cat, scp

---
## other Screenshot

![cloud-server-setup](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/e7d3fb4b3b86d2e62d6403a81cb81a13d41e7ad5/2026/day-08/images/server.jpg)

![copy file](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/e7d3fb4b3b86d2e62d6403a81cb81a13d41e7ad5/2026/day-08/images/scp.jpg)

![nginx service](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/e7d3fb4b3b86d2e62d6403a81cb81a13d41e7ad5/2026/day-08/images/nginx%20service.jpg)

![nginx logs](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/e7d3fb4b3b86d2e62d6403a81cb81a13d41e7ad5/2026/day-08/images/nginx%20logs.jpg)

---

## What I Learned
- Cloud server management
- SSH and security groups
- Service deployment and logs
