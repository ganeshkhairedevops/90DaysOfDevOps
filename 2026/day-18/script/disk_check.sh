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
