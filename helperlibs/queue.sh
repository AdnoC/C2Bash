#!/usr/bin/env bash
declare -gi QUEUE_EMPTY=982

declare -gi QUEUE_INDEX=0

function Queue() {
  local queuePrefix="__queue$QUEUE_INDEX"
  local queueVals=$queuePrefix"Values"
  local queueLength=$queuePrefix"Length"
  local queueLength=$queuePrefix"Length"
  if [ $# -gt 1 ]; then
    declare -gi "$queueLength=1"
    declare -ga "$queueVals=(\"$2\")"
  else
    declare -gi "$queueLength=0"
    declare -ga "$queueVals=()"
  fi
  declare -n ref=$1
  ref=$queuePrefix
  QUEUE_INDEX=$QUEUE_INDEX+1
  return 0
}

function Queue::push() {
  declare -n queue=${!1}Values
  declare -n  length=${!1}Length

  queue[$length]="$2"
  let length=length+1
  return 0
}

function Queue::peek() {
  declare -n queue=${!1}Values
  declare -n length=${!1}Length
  declare -n ret=$2

  if [ $length -gt 0 ]; then
    ret="${queue[0]}"
    return 0
  else
    # I know this will bite me in the ass, but whatever. I'm still returning > 0 anyways.
    ret=""
    return $QUEUE_EMPTY
  fi
}

function Queue::pop() {
  declare -n queue=${!1}Values
  declare -n length=${!1}Length
  if [ $# -gt 1 ]; then
    declare -n ret=$2
  else
    declare ret=''
  fi

  Queue::peek "$1" ret
  if [ $length -gt 0 ]; then
    let length=length-1
    queue=("${queue[@]:1:$(($length))}")
    return 0
  fi
  return $Queue_EMPTY
}

function Queue::length() {
  declare -n ret=$2
  declare -n length=${!1}Length
  ret=$length
  return 0
}
