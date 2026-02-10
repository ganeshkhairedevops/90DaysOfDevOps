# Day 17 – Shell Scripting: Loops, Arguments & Error Handling

Today I practiced advanced shell scripting concepts such as loops,
command-line arguments, package installation, and basic error handling.

---
## Task 1: For Loop
### Script: for_loop.sh
```bash
#!/bin/bash
for fruit in apple banana mango orange grape; do
  echo "$fruit"
done
```
### Script: count.sh
```bash
#!/bin/bash
for i in {1..10}; do
  echo $i
done
```
---
## Task 2: While Loop
### Script: countdown.sh
```bash
#!/bin/bash
read -p "Enter a number: " NUM
# Count down to 0
while [ "$NUM" -ge 0 ]; do
  echo $NUM
  NUM=$((NUM-1))
done
echo "Done!"
```
---
## Task 3: Command-Line Arguments
### Script: greet.sh
```bash
#!/bin/bash

if [ $# -eq 0 ]; then
  echo "Usage: ./greet.sh <name>"
  exit 1
fi

echo "Hello, $1!"
```
### Script: args_demo.sh
```bash
#!/bin/bash

echo "Script name: $0"
echo "Total arguments: $#"
echo "All arguments: $@"
```
---
## Task 4: Install Packages via Script
### Script: install_packages.sh
```bash
#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  echo "Please run this script as root"
  exit 1
fi

PACKAGES=("nginx" "curl" "wget")

for pkg in "${PACKAGES[@]}"; do
  if dpkg -s $pkg &> /dev/null; then
    echo "$pkg is already installed"
  else
    echo "Installing $pkg..."
    apt install -y $pkg
  fi
done
```
---
## Task 5: Error Handling
