# Day 14 – Networking Fundamentals & Hands-on Checks

Today I focused on core networking concepts and practical commands
used during real-world troubleshooting.

---

## Quick Concepts

### OSI vs TCP/IP
- OSI is a conceptual model (Layer 1–7)
- TCP/IP is the practical implementation

Mapping:
- OSI L1–L2 → Link
- OSI L3 → Internet
- OSI L4 → Transport
- OSI L5–L7 → Application
---

## Hands-on Networking Checks

Target: google.com

### Identity
```bash
hostname -I
```

### Reachability
```bash
ping google.com
```

### Network Path
```bash
traceroute google.com
```

### Listening Ports
```bash
ss -tulpn
```
---
![ss -tulpn](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/0ff9b2c1db8d9f278cebffbc9780c344ab182f11/2026/day-14/images/ss-tulpn.jpg)

---
### DNS Resolution
```bash
dig google.com
```

### HTTP Check
```bash
curl -I https://google.com
```
---
![curl ](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/aad305f8e0af44e253bde18fea4de99cf5b84bd1/2026/day-14/images/curl.jpg)

---

### Connections Snapshot
```bash
netstat -an | head
```
---
![netstat ](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/aad305f8e0af44e253bde18fea4de99cf5b84bd1/2026/day-14/images/netstat.jpg)

---


## Mini Task: Port Probe

```bash
nc -zv localhost 22
```

Observation:
- SSH port reachable

---

## Reflection

- Fastest signal: ping, curl
- DNS failure → Application layer
- HTTP 500 → Application issue

Follow-up checks:
- systemctl status <service>
- journalctl -u <service>

---

## Key Takeaways
- Layer-by-layer troubleshooting works
- Simple commands give fast insight
