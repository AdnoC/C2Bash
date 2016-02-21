#!/usr/bin/env bash

declare -gi __nextId=1

function resetNextId() {
  declare -gi __nextId=1
}

# Pointer::idName
function setId() {
  declare -n ref=$1
  ref=$__nextId
  let __nextId=__nextId+1
}
