#!/bin/bash

local_example() {
  local VAR="Inside function"
  echo "Inside: $VAR"
}

global_example() {
  VAR="Global variable"
}

local_example
global_example
echo "Outside: $VAR"
