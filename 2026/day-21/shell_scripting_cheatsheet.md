


#  Shell Scripting Cheat Sheet – DevOps Reference Guide

A practical quick-reference guide for daily DevOps scripting.

---

# 🔹 Quick Reference Table

| Topic | Key Syntax | Example |
|-------|------------|----------|
| Variable | VAR="value" | NAME="DevOps" |
| Argument | $1, $2 | ./script.sh arg1 |
| If | if [ condition ]; then | if [ -f file ]; then |
| For loop | for i in list; do | for i in 1 2 3; do |
| Function | name() { ... } | greet() { echo "Hi"; } |
| Grep | grep pattern file | grep -i "error" log.txt |
| Awk | awk '{print $1}' file | awk -F: '{print $1}' /etc/passwd |
| Sed | sed 's/old/new/g' file | sed -i 's/foo/bar/g' config.txt |

---

# 🔹 Basics

## Shebang
Defines the interpreter for the script.
```bash
#!/bin/bash
```

## Run Script
```bash
chmod +x script.sh
./script.sh
bash script.sh
```

## Variables
```bash
NAME="Ganesh"
echo "$NAME"
```

## Arguments
```bash
$0  # script name
$1  # first argument
$#  # number of arguments
$@  # all arguments
$?  # last exit code
```

---

# 🔹 Conditionals

```bash
if [ -f file ]; then
  echo "File exists"
fi
```

---

# 🔹 Loops

```bash
for i in 1 2 3; do
  echo $i
done
```

```bash
while read line; do
  echo $line
done < file.txt
```

---

# 🔹 Functions

```bash
greet() {
  echo "Hello $1"
}
greet "DevOps"
```

---

# 🔹 Text Processing

```bash
grep -i "error" file
awk '{print $1}' file
sed -i 's/foo/bar/g' file
cut -d: -f1 /etc/passwd
sort file | uniq -c
wc -l file
tail -f log.txt
```

---

# 🔹 Error Handling

```bash
set -euo pipefail
set -x
trap 'echo cleanup' EXIT
```

---

✔ Validate inputs  
✔ Use strict mode  
✔ Log outputs in production  
