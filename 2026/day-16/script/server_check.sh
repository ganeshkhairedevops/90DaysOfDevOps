#!/bin/bash

SERVICE="ssh"

read -p "Do you want to check the service status? (y/n): " CHOICE

if [ "$CHOICE" = "y" ]; then
  systemctl status $SERVICE
elif [ "$CHOICE" = "n" ]; then
  echo "Skipped."
else
  echo "Invalid choice"
fi
