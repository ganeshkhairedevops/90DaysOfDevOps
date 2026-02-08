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
- **A** → Maps domain name to IPv4 address
- **AAAA** → Maps domain name to IPv6 address
- **CNAME** → Alias pointing to another domain
- **MX** → Mail server records for email delivery
- **NS** → Name servers responsible for the domain

```bash
dig google.com
```

---
## Task 2: IP Addressing

1. What is an IPv4 address?
- A 32-bit address written in dotted decimal format
IPv4 example:
192.168.1.10
- Used to uniquely identify devices on a network

2. Public vs Private IP

- Public IP → Accessible over the internet (example: 8.8.8.8)

- Private IP → Used inside private networks (example: 192.168.1.10)

3. Private ranges:
- 10.0.0.0 – 10.255.255.255
- 172.16.0.0 – 172.31.255.255
- 192.168.0.0 – 192.168.255.255

4.  My system IP falls under private IP range
```bash
ip addr show
```

---

---

## Task 3: CIDR & Subnetting
1. What does /24 mean?
- /24 means 24 bits for network
2. Usable hosts
Hosts:
- /24 → 254
- /16 → 65534
- /28 → 14
3. Why do we subnet?
- To organize networks efficiently
- To improve security and isolation
- To reduce broadcast traffic
 
 ### CIDR Table:
- /24 → 255.255.255.0 → 256 IPs → 254 usable
- /16 → 255.255.0.0 → 65536 IPs → 65534 usable
- /28 → 255.255.255.240 → 16 IPs → 14 usable

---

## Task 4: Ports

1. What is a port?
- A port is a logical endpoint for network communication
- It allows multiple services to run on the same IP

## Common Ports
- 22 → SSH
- 80 → HTTP
- 443 → HTTPS
- 53 → DNS
- 3306 → MySQL
- 6379 → Redis
- 27017 → MongoDB

3. 

```bash
ss -tulpn
```
- SSH listening on port 22
- Other system services listening on known ports
---

## Task 5: Putting It Together
1. 
- DNS resolves myapp.com to an IP
- TCP connection on port 8080
- HTTP request sent at application layer

curl http://myapp.com:8080:

DNS → TCP → HTTP

2. App can’t reach DB at 10.0.1.50:3306 — what to check first?
- Network reachability (ping / private IP range)
- Port access (3306 open or not)
- Database service status
- Firewall or security group rules

DB issue at 10.0.1.50:3306:

Check reachability, port, service, firewall

---

## What I Learned
- Networking is layered
- CIDR helps network design
- Ports expose services
