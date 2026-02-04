# Day 12 – Revision & Breather (Days 01–11)

The focus was on retaining Linux fundamentals and reinforcing
commands I’ll actually use in real DevOps work.

---

## Mindset & Plan Review
- Goals from Day 01 are still valid
- Hands-on practice helped the most
- Will focus more on troubleshooting scenarios

---

## Processes & Services Re-check

```bash
ps aux | head
systemctl status nginx
journalctl -u nginx -n 10
```

Observation:
- nginx service running normally
- No recent errors found

---

## File Skills Practice

```bash
echo "revision test" >> notes.txt
chmod +x script.sh
ls -l script.sh
chown tokyo:developers devops-file.txt
```

---

## Cheat Sheet Refresh

Top 5 commands:
- systemctl status
- journalctl -u
- top
- df -h
- ls -l

---

## User / Group Sanity Check

```bash
id tokyo
groups tokyo
ls -l devops-file.txt
```

---

## Mini Self-Check

### Commands that save most time
- systemctl status
- journalctl -u
- ls -l

### Service health check
```bash
systemctl status <service>
journalctl -u <service> -n 20
ps aux | grep <service>
```

### Safe ownership/permission change
```bash
chown user:group filename
chmod 640 filename
```

--- 

### Key Takeaways
- Fundamentals matter
- Logs first, actions later
- Always verify changes
