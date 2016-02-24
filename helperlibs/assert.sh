#!/usr/bin/env bash
declare -g _INC_ASSERT=true
# Exit when we try to use an uninitialized variable
set -o nounset
# Exit if any function returns a non-true value 
set -o errexit

declare -g ASSERTION_ERROR=52

# String value1, String value2
function assertEqual() {
  if [ "$1" != "$2" ]; then
    echoerr "Assertion error. Source: $(caller)"
    echoerr "String1: $1"
    echoerr "String2: $2"
    if [ -n $__DEBUG ]; then
      echo $ASSERTION_ERROR
    fi
    return $ASSERTION_ERROR
  fi
}

# Int::bool1, Int::bool2
function assertBool() {
  if  ( [ "$1" -eq 0 ] &&  [ "$2" -ne 0 ] ) || ( [ "$1" -ne 0 ] && [ "$2" -eq 0 ] ); then
    echoerr "Assertion error. Source $(caller)"
    echoerr "Bool1: $1"
    echoerr "Bool2: $2"
    if [ -n $__DEBUG ]; then
      echo $ASSERTION_ERROR
    fi
    return $ASSERTION_ERROR
  fi
  return 0
}
