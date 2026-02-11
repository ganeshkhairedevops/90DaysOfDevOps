#!/bin/bash

greet() {
  echo "Hello, $1!"
}

add() {
  echo "Sum: $(($1 + $2))"
}

greet "Ganesh"
add 10 20
