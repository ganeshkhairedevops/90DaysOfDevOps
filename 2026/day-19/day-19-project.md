# Day 19 – Shell Scripting Project: Log Rotation, Backup & Crontab

Today I built practical automation scripts for log rotation and backups,
and learned how to schedule them using cron.

---

## Task 1: Log Rotation Script

### Script: log_rotate.sh
```bash
#!/bin/bash
set -euo pipefail

if [ $# -ne 1 ]; then
  echo "Usage: $0 <log_directory>"
  exit 1
fi

LOG_DIR="$1"

if [ ! -d "$LOG_DIR" ]; then
  echo "Error: Directory does not exist"
  exit 1
fi

COMPRESSED=$(find "$LOG_DIR" -name "*.log" -mtime +7 | wc -l)
find "$LOG_DIR" -name "*.log" -mtime +7 -exec gzip {} \;

DELETED=$(find "$LOG_DIR" -name "*.gz" -mtime +30 | wc -l)
find "$LOG_DIR" -name "*.gz" -mtime +30 -delete

echo "Compressed files: $COMPRESSED"
echo "Deleted files: $DELETED"
```
---
## Task 2: Server Backup Script

### Script: backup.sh
```bash
#!/bin/bash

<<info
Simple Production Backup Script
Usage: ./backup.sh <source_directory> <backup_destination>
info

set -euo pipefail
# ---- Argument Validation ----
if [ $# -ne 2 ]; then
  echo "Usage: $0 <source_directory> <backup_destination>"
  exit 1
fi

SOURCE="$1"
DEST="$2"

# ---- Validate Source ----
if [ ! -d "$SOURCE" ]; then
  echo "Error: Source directory does not exist: $SOURCE"
  exit 1
fi

# ---- Create Destination if Missing ----
mkdir -p "$DEST"

# ---- Setup Variables ----
TIMESTAMP=$(date +%Y-%m-%d)
ARCHIVE="$DEST/backup-$TIMESTAMP.tar.gz"
LOGFILE="$DEST/backup.log"

SOURCE_DIR=$(dirname "$SOURCE")
SOURCE_BASE=$(basename "$SOURCE")

echo "----------------------------------------" >> "$LOGFILE"
echo "Backup started at $(date)" >> "$LOGFILE"
echo "Source: $SOURCE" >> "$LOGFILE"
echo "Destination: $ARCHIVE" >> "$LOGFILE"

# ---- Create Archive (Clean Method) ----
if tar -czf "$ARCHIVE" -C "$SOURCE_DIR" "$SOURCE_BASE"; then
    echo "Backup created successfully: $ARCHIVE"
    ls -lh "$ARCHIVE"

    echo "Backup successful at $(date)" >> "$LOGFILE"
    echo "Archive size: $(du -h "$ARCHIVE" | cut -f1)" >> "$LOGFILE"
else
    echo "Backup failed!"
    echo "Backup FAILED at $(date)" >> "$LOGFILE"
    exit 1
fi

# ---- Cleanup Old Backups (Older than 14 Days) ----
find "$DEST" -name "backup-*.tar.gz" -mtime +14 -print -delete >> "$LOGFILE" 2>&1

echo "Old backups cleanup completed at $(date)" >> "$LOGFILE"
echo "----------------------------------------" >> "$LOGFILE"

exit 0

```
---

## Task 3: Crontab

Check existing cron jobs:
```bash
crontab -l
```
Run log rotation daily at 2 AM
```bash 
0 2 * * * /root/90DaysOfDevOps/2026/day-19/script/log_rotate.sh ~/log-test
```
Run backup every Sunday at 3 AM
```bash
0 3 * * 0 /root/90DaysOfDevOps/2026/day-19/script/backup.sh /root/2026 /root/backup
```
Run health check every 5 minutes
```bash
*/5 * * * * /path/to/health_check.sh
```
## Task 4: Combine — Scheduled Maintenance Script
### Script: maintenance.sh
```bash
#!/bin/bash

LOG_FILE="/var/log/maintenance.log"

# Function to add timestamp
timestamp() {
    date "+%Y-%m-%d %H:%M:%S"
}

{
    echo "==============================="
    echo "Maintenance started at $(timestamp)"

    echo "Running log rotation..."
    bash /root/90DaysOfDevOps/2026/day-19/script/log_rotate.sh ~/log-test

    echo "Running backup..."
    bash /root/90DaysOfDevOps/2026/day-19/script/backup.sh /root/2026 /root/backup

    echo "Maintenance completed at $(timestamp)"
    echo "==============================="
    echo ""

} >> "$LOG_FILE" 2>&1

```

check log file
```bash
cat /var/log/maintenance.log
```

---
Cron Entry (Daily at 1 AM)
- Open crontab:
```bash
crontab -e
```
Add this line:

```bash
0 1 * * * /root/90DaysOfDevOps/2026/day-19/script/maintenance.sh
```
---
## Cron Timing Explained
```bash
0 1 * * *
│ │ │ │ │
│ │ │ │ └── Day of week
│ │ │ └──── Month
│ │ └────── Day of month
│ └──────── Hour (1 AM)
└────────── Minute (0)
```
---
## What I Learned
- Validation and error handling are critical in automation
- Strict mode prevents silent failures
- Cron scheduling is powerful for DevOps maintenance tasks