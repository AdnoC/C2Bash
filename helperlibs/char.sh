#!/usr/bin/env bash
include "$C2BASH_HOME"/helperlibs/return.sh

# If passed a string only converts the first char
# Pointer::int, String::char
function Char::toInt() {
  @return "$(printf '%d' "'$2")"
  return 0
}
