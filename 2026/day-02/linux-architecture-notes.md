# Linux Architecture – Day 02

These notes are written to understand how Linux actually works in real systems,
especially for debugging and production issues.

---

## Core Parts of Linux

### Kernel
- Kernel is the main part of Linux
- It talks directly to hardware
- It manages:
  - CPU scheduling
  - Memory
  - Processes
  - Disk and network
- Applications do NOT access hardware directly
- Everything goes through the kernel

---

### User Space
- This is where users and applications work
- Examples:
  - bash shell
  - commands like ls, ps, top
  - services like nginx, docker
- User space programs request help from kernel using system calls

---

### systemd (Init System)
- systemd is the first process started by Linux
- It always has **PID 1**
- Responsible for:
  - Starting services
  - Restarting failed services
  - Managing dependencies
- Almost all servers use systemd today

---

## Process Creation & Management

- A process is a running program
- New processes are created using:
  - `fork()` – creates a copy
  - `exec()` – loads a new program
- Every process has:
  - PID → process ID
  - PPID → parent process ID
- Kernel decides which process gets CPU time

---

## Process States (Very Important)

- **R (Running):** Process is using CPU
- **S (Sleeping):** Waiting for something (normal state)
- **D:** Waiting for disk or network (cannot be killed easily)
- **T:** Stopped manually
- **Z (Zombie):** Process ended but parent didn’t clean it

Zombie processes mean bad process handling.

---

## Why systemd Matters in DevOps

- Starts services automatically on boot
- Restarts services if they crash
- Maintains service order
- Central logging using journalctl

In production, most issues are solved using systemd logs and status.

---

## Linux Commands I Use Daily

- `ps aux` → list running processes
- `top` → check CPU and memory usage
- `systemctl status service-name` → show status of service
- `free` → show memory
- `kill PID` / `kill -9 PID`
- `df -h` → show disk space
- `ls -l` → lists files and directories in long format showing permissions

---

## Final Notes
Linux understanding is required to:
- Debug crashed services
- Fix high CPU or memory usage
- Handle real production incidents
