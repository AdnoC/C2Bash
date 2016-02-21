#!/usr/bin/env bash

# If passed a string only converts the first char
# Pointer::ret, String::char
function Char::toInt() {
  declare -n ret=$1
  ret=$(printf '%d' "'$2")
}
