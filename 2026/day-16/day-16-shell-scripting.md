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

![task 1 ](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/566337d7c69129c40f967655b27f83bd3905f5eb/2026/day-16/images/task%201.jpg)

---
## Task 2: Variables

### Script: variables.sh
```bash
#!/bin/bash
NAME="Ganesh"
ROLE="Devops Engineer"
echo "Hello, I am $NAME and I am a $ROLE."
```
### Steps to Run:
1. Create the script file:
   ```bash
   nano variables.sh
   ```
2. Make it executable:
   ```bash
    chmod +x variables.sh
    ./variables.sh
   ```
### Single quotes vs Double quotes
- Single quotes (' ') → variables are NOT expanded
- Double quotes (" ") → variables ARE expanded

---
## Task 3: User Input with read

### Script: greet.sh
```bash
#!/bin/bash
read -p "Enter your name: " NAME
read -p "Enter your favourite tool: " TOOL
echo "Hello $NAME, your favourite tool is $TOOL."
```
### Steps to Run:
1. Create the script file:
   ```bash
   nano greet.sh
   ```
2. Make it executable:
   ```bash
    chmod +x greet.sh
    ./greet.sh
   ```
---
## Task 4: If-Else Conditions
### 1. Script: check_number.sh
```bash
#!/bin/bash

read -p "Enter a number: " NUM

if [ "$NUM" -gt 0 ]; then
  echo "Number is positive"
elif [ "$NUM" -lt 0 ]; then
  echo "Number is negative"
else
  echo "Number is zero"
fi

```
### 2. Script: file_check.sh
```bash
#!/bin/bash

read -p "Enter a number: " NUM

if [ "$NUM" -gt 0 ]; then
  echo "Number is positive"
elif [ "$NUM" -lt 0 ]; then
  echo "Number is negative"
else
  echo "Number is zero"
fi
```
---
## Task 5: Combine It All
### Script: server_check.sh
```bash
#!/bin/bash

SERVICE="ssh"

read -p "Do you want to check the service status? (y/n): " CHOICE

if [ "$CHOICE" = "y" ]; then
  systemctl status $SERVICE
elif [ "$CHOICE" = "n" ]; then
  echo "Skipped."
else
  echo "Invalid choice"
fi
```
---
## What I Learned
- Shebang defines interpreter
- Variables and read make scripts dynamic
- if-else controls flow