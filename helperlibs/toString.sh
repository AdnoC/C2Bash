#!/usr/bin/env bash

# Pointer::stringRep, bool
function boolToString() {
  declare -n str=$1
  if [ "$2" -eq 0 ]; then
    str="True"
  else
    str="False"
  fi
}
