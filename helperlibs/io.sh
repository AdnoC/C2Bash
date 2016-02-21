#!/usr/bin/env bash
declare -gi __DEBUGTAB=0

function incrementDebugTab() {
  declare -i val=1
  if [ $# -ne 0 ]; then
    val=$1
  fi
  __DEBUGTAB=$__DEBUGTAB+$val
}

function decrementDebugTab() {
  declare -i val=1
  if [ $# -ne 0]; then
    val=$1
  fi
  __DEBUGTAB=$__DEBUGTAB+$val
}

function echotab() {
  local debugTab=0
  declare -i stackLength=${#FUNCNAME[@]}+$__DEBUGTAB
  local tabStr=""
  while [ $debugTab -lt $stackLength ]; do
    tabStr=" $tabStr"
    let debugTab=debugTab+1
  done
  builtin echo "$tabStr$1"
}

function echoerr() {
  >&2 echotab "$@"
  # local debugTab=0
  # declare -i stackLength=${#FUNCNAME[@]}
  # builtin echo $stackLength
  # #+$__DEBUGTAB
  # local tabStr=""
  # while [ $debugTab -lt $stackLength ]; do
  #   tabStr=" $tabStr"
  # done
  # >&2 builtin echo "$tabStr$1"
}

