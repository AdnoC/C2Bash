#!/usr/bin/env bash
include "$C2BASH_HOME"/helperlibs/return.sh
include "$C2BASH_HOME"/helperlibs/array.sh

declare -gi __nextId=1
declare -ga __idMap
Array __idMap

function resetNextId() {
  declare -gi __nextId=1
  declare -ga __idMap
  Array __idMap
}

# Pointer::idName
function setId() {
  declare -g __nextId
  Array::set __idMap "$__nextId" "$1"
  @return "$__nextId"
  declare -g __nextId
  let __nextId=__nextId+1
}

# Pointer::idMap
function getIdMap() {
  @return "$__idMap"
}
