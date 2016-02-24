#!/usr/bin/env bash
include "$C2BASH_HOME"/helperlibs/return.sh

declare -gi __nextId=1

function resetNextId() {
  declare -gi __nextId=1
}

# Pointer::id
function setId() {
  declare -g __nextId
  @return "$__nextId"
  declare -g __nextId
  let __nextId=__nextId+1
}
