#!/bin/bash
set -euo pipefail

# =========================
# Task 1: Input Validation
# =========================

if [ $# -ne 1 ]; then
    echo "Usage: $0 <log_file>"
    exit 1
fi

LOG_FILE="$1"

if [ ! -f "$LOG_FILE" ]; then
    echo "Error: File does not exist"
    exit 1
fi

DATE=$(date +%Y-%m-%d)
REPORT_FILE="log_report_${DATE}.txt"

TOTAL_LINES=$(wc -l < "$LOG_FILE")

# =========================
# Task 2: Error Count
# =========================

ERROR_COUNT=$(grep -E "ERROR|Failed" "$LOG_FILE" | wc -l)

echo "Total Errors Found: $ERROR_COUNT"

# =========================
# Task 3: Critical Events
# =========================

CRITICAL_EVENTS=$(grep -n "CRITICAL" "$LOG_FILE" || true)

# =========================
# Task 4: Top 5 Error Messages
# =========================

TOP_ERRORS=$(grep "ERROR" "$LOG_FILE" \
    | awk '{$1=$2=""; print substr($0,3)}' \
    | sort \
    | uniq -c \
    | sort -rn \
    | head -5)

# =========================
# Task 5: Generate Report
# =========================

{
echo "===== Log Analysis Report ====="
echo "Date of Analysis: $DATE"
echo "Log File: $LOG_FILE"
echo "Total Lines Processed: $TOTAL_LINES"
echo "Total Error Count: $ERROR_COUNT"
echo
echo "--- Top 5 Error Messages ---"
echo "$TOP_ERRORS"
echo
echo "--- Critical Events ---"
echo "$CRITICAL_EVENTS"
} > "$REPORT_FILE"

echo "Report generated: $REPORT_FILE"

# =========================
# Task 6: Archive Log (Optional)
# =========================

mkdir -p archive
mv "$LOG_FILE" archive/
echo "Log file moved to archive/"
