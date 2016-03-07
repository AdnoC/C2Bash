#!/usr/bin/env bash
include "$C2BASH_HOME"/helperlibs/array.sh

declare -gi __DEBUGTAB=0

# Int::amount
function incrementDebugTab() {
  declare -i val=1
  if [ $# -ne 0 ]; then
    val=$1
  fi
  __DEBUGTAB=$__DEBUGTAB+$val
}

# Int::amount
function decrementDebugTab() {
  declare -i val=1
  if [ $# -ne 0 ]; then
    val=$1
  fi
  __DEBUGTAB=$__DEBUGTAB-$val
}


function echoIndent() {
  local debugTab=0
  declare -i stackLength=${#FUNCNAME[@]}+$__DEBUGTAB
  local tabStr=""
  while [ $debugTab -lt $stackLength ]; do
    tabStr=" $tabStr"
    let debugTab=debugTab+1
  done
  builtin echo "$tabStr"
  return 0
}

# String::str
function echotab() {
  local debugTab=0
  declare -i stackLength=${#FUNCNAME[@]}+$__DEBUGTAB
  local tabStr=""
  while [ $debugTab -lt $stackLength ]; do
    tabStr=" $tabStr"
    let debugTab=debugTab+1
  done
  builtin echo "$tabStr$1"
  return 0
}

# String::errString
function echoerr() {
  >&2 echotab "$@"
  return 0
}

# Pointer::array, Pointer::keyMap
function echoArray() {
  declare -n array="${!1}"

  declare keyStr
  for key in "${!array[@]}"; do
    if [ -z "$2" ] || ! Array::isArray "$2"; then
      keyStr="$key"
    else
      Array::get keyStr "$2" "$key"
    fi
    printf "%s%s -> " "$(echoIndent)" "$keyStr"

    if Array::isArray "array[$key]"; then
      printf "array (\n"
      incrementDebugTab
      echoArray "array[$key]" "$2"
      decrementDebugTab
      printf "%s)\n" "$(echoIndent)"
    else
      printf "%s\n" "${array[$key]}"
    fi
  done

  return 0
}
