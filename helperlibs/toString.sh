#!/usr/bin/env bash
include "$C2BASH_HOME"/helperlibs/return.sh

# Pointer::stringRep, Int::bool
function boolToString() {
  if [ "$2" -eq 0 ]; then
    @return "True"
  else
    @return "False"
  fi
}
