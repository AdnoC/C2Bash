#!/usr/bin/env bash
include "$C2BASH_HOME"/helperlibs/return.sh
declare -gi QUEUE_EMPTY=982

declare -gi QUEUE_INDEX=0

# Pointer::queueRefVar, String::initialValue
function Queue() {
  local queuePrefix="__queue$QUEUE_INDEX"
  local queueVals=$queuePrefix"Values"
  local queueLength=$queuePrefix"Length"
  if [ $# -gt 1 ]; then
    declare -gi "$queueLength=1"
    declare -ga "$queueVals=(\"$2\")"
  else
    declare -gi "$queueLength=0"
    declare -ga "$queueVals=()"
  fi

  QUEUE_INDEX=$QUEUE_INDEX+1
  @return "$queuePrefix"
  return 0
}

function Queue::push() {
  declare -n queue=${!1}Values
  declare -n length=${!1}Length

  queue[$length]="$2"
  let length=length+1
  return 0
}

# Pointer::element, Pointer::queuePrefixVar
function Queue::peek() {
  declare -n queue=${!2}Values
  declare -n length=${!2}Length

  if [ $length -gt 0 ]; then
    @return "${queue[0]}"
    return 0
  else
    return $QUEUE_EMPTY
  fi
}

# Pointer::queuePrefixVar
# Pointer::element, Pointer::queuePrefixVar
function Queue::pop() {
  declare argLen="$#"
  declare prefixVar=${!argLen}
  declare -n queue=${!prefixVar}Values
  declare -n length=${!prefixVar}Length

  if [ $length -gt 0 ]; then
    declare elem
    Queue::peek elem "$prefixVar" 

    let length=length-1
    queue=("${queue[@]:1:$(($length))}")

    if [ $# -gt 1 ]; then
      @return "$elem"
    fi
    return 0
  fi
  return $Queue_EMPTY
}

# Pointer::length, Pointer::queuePrefixVar
function Queue::length() {
  declare -n length=${!2}Length
  @return "$length"
  return 0
}
