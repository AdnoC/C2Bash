#!/usr/bin/env bash
include "$C2BASH_HOME"/helperlibs/return.sh
declare -gi STACK_EMPTY=987

declare -gi STACK_INDEX=0

# Pointer::stackPrefixVar, String::initialValue
function Stack() {
  local stackPrefix="__stack$STACK_INDEX"
  # Store the values of the stack in a separate thing from just the prefix since we shouldn't be accessing stacks other than shifting unshiftping and peeking.
  local stackVals=$stackPrefix"Values"
  local stackLength=$stackPrefix"Length"
  if [ $# -gt 1 ]; then
    declare -gi "$stackLength=1"
    declare -ga "$stackVals=(\"$2\")"
  else
    declare -gi "$stackLength=0"
    declare -ga "$stackVals=()"
  fi
  @return "$stackPrefix"
  STACK_INDEX=$STACK_INDEX+1
  return 0
}

# Pointer::stackPrefixVar
function Stack::shift() {
  declare -n stck=${!1}Values
  declare -n  length=${!1}Length
  stck[$length]="$2"
  let length=length+1
  return 0
}

# Pointer::element, Pointer::stackPrefixVar
function Stack::peek() {
  declare -n stck=${!2}Values
  declare -n length=${!2}Length

  if [ $length -gt 0 ]; then
    @return "${stck[$length-1]}"
    return 0
  else
    return $STACK_EMPTY
  fi
}

# Pointer::stackPrefixVar
# Pointer::element, Pointer::stackPrefixVar
function Stack::unshift() {
  declare argLen="$#"
  declare prefixVar=${!argLen}
  declare -n length=${!prefixVar}Length

  if [ $length -gt 0 ]; then
    declare elem
    Stack::peek elem "$prefixVar"

    if [ $# -gt 1 ]; then
      @return "$elem"
    fi

    let length=length-1
    return 0
  fi
  return $STACK_EMPTY
}

# Pointer::length, Pointer::stackPrefixVar
function Stack::length() {
  declare -n length=${!2}Length
  @return "$length"
  return 0
}
