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

