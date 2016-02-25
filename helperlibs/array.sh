#!/usr/bin/env bash
include "$C2BASH_HOME"/helperlibs/return.sh

declare -gi NOT_IN_ARRAY=243
declare -gi NEXT_ARRAY_INDEX=0

# Stacks and Queues are Arrays, but not all Arrays are not Stacks or Queues
# Pointer::arrayRefVar, String::initialValue
function Array() {
  local arrayPrefix="__array$NEXT_ARRAY_INDEX"
  local arrayVals=$arrayPrefix"Values"
  if [ $# -gt 1 ]; then
    declare -ga "$arrayVals=(\"$2\")"
  else
    declare -ga "$arrayVals=()"
  fi

  NEXT_ARRAY_INDEX=$NEXT_ARRAY_INDEX+1
  @return "$arrayPrefix"
  return 0
}

# Pointer::element, String::array, Int::index
function Array::get() {
  declare -n array=${!1}Values
  @return "${array[$3]}"
  return 0
}

# Pointer::array, Int::index, String::value
function Array::set {
  declare -n array=${!1}Values
  array[$2]="$3"
  return 0
}
#
# Pointer::oldValue, Pointer::array, Int::index, String::value
function Array::replace {
  declare -n array=${!2}Values
  declare oldVal
  oldVal="${arrray[$3]}"
  array[$3]="$4"

  @return "$oldVal"
  return 0
}

# Pointer::array, Int::index
# Pointer::oldValue, Pointer::array, Int::index
function Array::unset() {
  declare argLen="$#"
  let argLen=argLen-1
  declare prefixVar=${!argLen}
  declare -n array=${!prefixVar}Values

  declare oldVal
  oldVal="${array[$#]}"
  unset array["$#"]
  if [ "$#" -eq "3" ]; then
    @return "$oldVal"
  fi
  return 0
}

# Pointer::length, Pointer::array
function Array::length() {
  declare -n array=${!2}Values
  @return "${#array}"
  return 0
}

# Pointer::iterationString, Pointer::array
function Array::iterationString() {
  declare iterString="${!2}Values"
  @return "$iterString"
  return 0
}

# Returns solely via return code
# Pointer::array, String::value
function Array::inArray() {
  declare arrayName=${!1}
  if [[ "$arrayName" =~ ^(__stack|__queue).* ]]; then
    declare -n array=$arrayName"Values"
  else
    declare -n array=${!1}
  fi
  for element in "${array[@]}"; do
    if [[ "$2" == "$element" ]]; then
      return 0
    fi
  done
  return $NOT_IN_ARRAY
}

# Adds all the values of one array to another. Doesn't garuntee to preserve spacing between values of the second array
# Maybe should be called concat instead of merge
# Pointer::arrayToMergeInto, Pointer::array2
function Array::merge() {
  declare -n array1=${!1}Values
  declare -n array2=${!2}Values
  array1+=("${array2[@]}")
  return 0
}
