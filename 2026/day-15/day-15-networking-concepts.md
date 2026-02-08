# Day 15 – Networking Concepts: DNS, IP, Subnets & Ports

Today I focused on understanding the core networking concepts
that every DevOps engineer must know.

---
## Task 1: DNS – How Names Become IPs

When I type google.com in a browser:
- DNS resolver checks cache
- Query is sent to DNS servers
- IP address is returned
- Browser connects using HTTP/HTTPS

DNS Records:
- A: IPv4 address
- AAAA: IPv6 address
- CNAME: Alias record
- MX: Mail server record
- NS: Name server record

```bash
dig google.com
```

---
