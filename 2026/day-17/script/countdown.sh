#!/bin/bash
read -p "Enter a number: " NUM
# Count down to 0
while [ "$NUM" -ge 0 ]; do
  echo $NUM
  NUM=$((NUM-1))
done
echo "Done!"
