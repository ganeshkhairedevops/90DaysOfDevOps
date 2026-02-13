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

