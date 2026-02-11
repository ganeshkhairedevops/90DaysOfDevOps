# Day 18 – Shell Scripting: Functions & Advanced Concepts

Today I learned how to write cleaner and safer shell scripts using functions,
strict mode, return values, and reusable patterns.

---
## Task 1: Basic Functions
### Script: functions.sh

```bash
#!/bin/bash

greet() {
  echo "Hello, $1!"
}

add() {
  echo "Sum: $(($1 + $2))"
}

greet "Ganesh"
add 10 20
```
---
### Explanation:
- We defined two functions: `greet` and `add`.
- `greet` takes one argument and prints a greeting message.
- `add` takes two arguments, calculates their sum, and prints the result.
---
![task 1](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/18963c58a52d6243374f287fbd969b710a136db9/2026/day-18/images/task%201.jpg)

---
## Task 2: Functions with Return Values
### Script: disk_check.sh
```bash
#!/bin/bash

check_disk() {
  df -h
}
check_memory() {
  free -h
}
main() {
  echo "Disk Usage:"
  check_disk

  echo
  echo "Memory Usage:"
  check_memory
}

main
```
---
![task 2](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/3137d629401004c6b7dc57dfd773a9cdb667ad66/2026/day-18/images/task%202.jpg)
---

## Task 3: Strict Mode – set -euo pipefail
### Script: strict_demo.sh
```bash
#!/bin/bash
set -euo pipefail

echo "Strict mode enabled"

# Uncomment to test:
# echo $UNDEFINED_VAR
# false
# false | true
```
## What each flag does:
- set -e → Script exits immediately if any command fails
- set -u → Script fails when an undefined variable is used
- set -o pipefail → Script fails if any command in a pipeline fails

---
## Task 4:  Local Variables
### Script: local_demo.sh
```bash
#!/bin/bash

local_example() {
  local VAR="Inside function"
  echo "Inside: $VAR"
}

global_example() {
  VAR="Global variable"
}

local_example
global_example
echo "Outside: $VAR"
```
- local variables do not leak outside the function
- Global variables can be overwritten accidentally

## Task 5: System Info Reporter Script
### Script: system_info.sh
```bash
#!/bin/bash
set -euo pipefail
print_header() {
  echo "=============================="
  echo "$1"
  echo "=============================="
}
host_info() {
  hostnamectl
}
uptime_info() {
  uptime
}
disk_info() {
  du -h /var/log 2>/dev/null | sort -hr | head -5
}
memory_info() {
  free -h
}
cpu_info() {
  ps aux --sort=-%cpu | head -5
}
main() {
  print_header "Host Information"
  host_info

  print_header "Uptime"
  uptime_info

  print_header "Disk Usage (Top 5)"
  disk_info

  print_header "Memory Usage"
  memory_info

  print_header "Top CPU Processes"
  cpu_info
}

main
```
---
## What I Learned
- Functions make scripts reusable and readable
- Strict mode avoids hidden failures
- Local variables prevent side effects
-Structured scripts are easier to debug and extend
