# Linux Troubleshooting Runbook – Day 05

## Target Service
- Service: ssh
- Purpose: Remote server access
- Reason chosen: Critical service, always running

---

## Environment Basics

Command:
uname -a

Observation:
- Confirms kernel version and architecture

Command:
cat /etc/os-release

Observation:
- System is Ubuntu-based Linux

---

## Filesystem Sanity Check

Command:
mkdir /tmp/runbook-demo
cp /etc/hosts /tmp/runbook-demo/hosts-copy
ls -l /tmp/runbook-demo

Observation:
- Disk is writable
- File operations working normally

Command:
df -h

Observation:
- Root filesystem has sufficient free space

---

## CPU & Memory Snapshot

Command:
top

Observation:
- CPU usage is low
- No abnormal spikes

Command:
ps -o pid,pcpu,pmem,comm -C sshd

Observation:
- sshd using minimal resources

Command:
free -h

Observation:
- Memory usage normal

---

## Disk & IO Snapshot

Command:
du -sh /var/log

Observation:
- Log size normal

Command:
vmstat 1 5

Observation:
- No IO wait spikes

---

## Network Snapshot

Command:
ss -tulpn | grep ssh

Observation:
- SSH listening on port 22

Command:
curl -I localhost

Observation:
- Network responding normally

---

## Logs Reviewed

Command:
journalctl -u ssh -n 50

Observation:
- Normal activity

Command:
tail -n 50 /var/log/auth.log

Observation:
- No authentication errors

---

## Quick Findings
- Service healthy
- No resource pressure
- Logs clean

---
