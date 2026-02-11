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
