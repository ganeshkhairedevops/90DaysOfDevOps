#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  echo "Please run this script as root"
  exit 1
fi

PACKAGES=("nginx" "curl" "wget")

for pkg in "${PACKAGES[@]}"; do
  if dpkg -s $pkg &> /dev/null; then
    echo "$pkg is already installed"
  else
    echo "Installing $pkg..."
    apt install -y $pkg
  fi
done
