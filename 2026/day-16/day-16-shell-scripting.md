# Day 16 – Shell Scripting Basics

Today I started learning shell scripting fundamentals.
Shell scripts help automate repetitive tasks in DevOps.

---
## Task 1: My First Script

### Script: hello.sh
```bash
#!/bin/bash
echo Hello, Devops!
```
### Steps to Run:
1. Create the script file:
   ```bash
   touch hello.sh
   ```
2. Make it executable:
   ```bash
    chmod +x hello.sh
    ./hello.sh
   ```
## What happens if the shebang is removed?
- Without #!/bin/bash, the system doesn’t know which interpreter to use
- Running ./hello.sh may fail or behave unexpectedly
- Shebang ensures the script runs using Bash
---
