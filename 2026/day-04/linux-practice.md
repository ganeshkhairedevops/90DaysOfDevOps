# Linux Practice – Day 04

This file contains Linux commands understand process services and logs.

---

## 🔹 Process Checks

### 1. Check running processes
Command:
ps aux | head

Observation:
- Shows list of running processes
- Columns include USER, PID, CPU, MEM

---

### 2. Live process monitoring
Command:
top

Observation:
- Saw CPU and memory usage in real time
- Identified resource-heavy processes

---

## 🔹 Service Checks (systemd)

### 3. Check ssh service status
Command:
systemctl status ssh

Observation:
- Service is active and running
- Shows main PID and recent logs

---

### 4. List active services
Command:
systemctl list-units --type=service --state=running

Observation:
- Displays all running system services

---

## 🔹 Log Checks

### 5. View ssh service logs
Command:
journalctl -u ssh --no-pager | tail -n 20

Observation:
- Shows recent ssh activity

---

### 6. Check system logs
Command:
journalctl -xe

Observation:
- Shows recent system errors

---

## 🔹 Mini Troubleshooting Flow

1. Check service status
2. Verify process is running
3. Inspect logs
4. Restart service
5. Monitor system again

---

## 📸 Command Output Screenshot

![linux practice](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/88a37de07fc95c24da75fd12d7844f59b85c9b96/2026/day-04/day4%20systemctl.JPG)


![linux practice](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/a4fef5450084fc85fe06f8913c27b9bb7cf5bbc9/2026/day-04/day4.JPG)