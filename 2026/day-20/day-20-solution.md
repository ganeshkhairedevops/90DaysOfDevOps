# Day 20 – Bash Scripting Challenge: Log Analyzer & Report Generator

Today I built a real-world log analysis automation script.

The script processes system log files, identifies errors and critical events,
and generates a structured summary report.

---

## 🔹 Approach

### 1️⃣ Input Validation
- Checked if log file argument was provided
- Verified file existence before processing
- Used strict mode (set -euo pipefail)

---

### 2️⃣ Error Counting
Used:
grep -E "ERROR|Failed"
wc -l

To count total error occurrences.

---

### 3️⃣ Critical Events
Used:
grep -n "CRITICAL"

To print line numbers along with event messages.

---

### 4️⃣ Top Error Messages
Pipeline used:
grep → awk → sort → uniq -c → sort -rn → head -5

Tools used:
- grep (pattern matching)
- awk (field manipulation)
- sort
- uniq
- wc

---

### 5️⃣ Report Generation
Generated a structured report:
log_report_<date>.txt

Included:
- Date
- Log file name
- Total lines processed
- Total error count
- Top 5 errors
- Critical events

---

### 6️⃣ Archive Feature
- Created archive/ directory if not present
- Moved processed log file into archive/

---

## 🔹 Sample Output

Total Errors Found: 87
Report generated: log_report_2026-02-16.txt
Log file moved to archive/

---

## 🧠 What I Learned

- Log analysis is about pattern extraction and aggregation
- Bash pipelines are powerful for text processing
- Structured reports improve operational visibility
- Always validate inputs in automation scripts

---

## 🔹 Commands Used

grep
awk
sort
uniq
wc
date
mv
mkdir
