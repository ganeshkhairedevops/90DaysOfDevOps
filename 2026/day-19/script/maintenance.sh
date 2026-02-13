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

