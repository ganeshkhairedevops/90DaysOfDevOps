# Linux Commands Cheat Sheet – Day 03

This file contains Linux commands I use during daily work and production issues.
Short notes included for quick reference.

---

## 🧠 Process Management

- `ps aux` → show all running processes
- `ps -ef` → process list with parent IDs
- `top` → live CPU and memory usage
- `htop` → better version of top
- `uptime` → system running time and load
- `free -m` → check memory usage
- `kill PID` → stop a process gracefully
- `kill -9 PID` → force kill processes

---

## 📂 File System & Logs

- `ls -lh` → list files with size
- `pwd` → show current directory
- `cd /path` → change directory
- `df -h` → disk usage
- `du -sh *` → size of files/folders
- `mount` → mounted file systems
- `tail -f file.log` → follow log file live
- `less file.log` → scroll log safely
- `grep "error" file.log` → search text in logs
- `find / -name filename` → locate files
- `cp -r folder1/ folder2/` → copy directories
---

## 🌐 Networking & Connectivity

- `ping host` → check network connectivity
- `ip addr` → show IP addresses
- `ip route` → check routing table
- `ss -tulnp` → open ports and listening services
- `curl url` → test HTTP/HTTPS endpoint
- `dig domain` → DNS lookup
- `netstat -tulnp` → legacy network check

---

## 🛠️ Service & System

- `systemctl status service` → check service status
- `systemctl restart service` → restart service
- `whoami` → current user
- `hostnamectl` → system hostname info
- `sudo apt update` → Refresh package list
- `sudo apt install <package_name>` → install a software package
-  `sudo apt upgrade` → Install available updates
--- 

## 📝 Notes
These commands help me quickly:
- Identify high CPU/memory usage
- Debug service crashes
- Check logs and network issues
