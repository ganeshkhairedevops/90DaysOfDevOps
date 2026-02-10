#!/bin/bash
set -e

mkdir /tmp/devops-test || echo "Directory already exists"
cd /tmp/devops-test
touch test.txt

echo "Script completed successfully"
