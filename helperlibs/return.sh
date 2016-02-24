#!/usr/bin/env bash

set -o functrace
shopt -s expand_aliases
# alias @return='echo "RETURN PARAM: $*" '
alias @return='@return "$*" '

# Use global variables to 
declare -g __RETURN___RETURN_REFS
declare -g __RETURN_INDEX
declare -g __RETURN_DEPTH
declare -g __RETURN_REF

# Pass __RETURN_REFS with a quoted $*
# String::__RETURN_REFS, ...String::value
function @return() {
  unsetTrap
  declare -p retLen
  declare -g __RETURN_DEPTH="${#FUNCNAME[@]}"
  let __RETURN_DEPTH=__RETURN_DEPTH-1
  declare -a __RETURN_REFS=($1)
  shift
  declare -g __RETURN_REF
  declare -g __RETURN_INDEX=0
  declare -g __RETURN_VAL
  for __RETURN_VAL in "$@"; do
    if [ "${#__RETURN_REFS[@]}" -le "$__RETURN_INDEX" ]; then
      >&2 echo "Tried to return more values than pointers were given"
      break;
    fi

    declare -gn __RETURN_REF="${__RETURN_REFS[$__RETURN_INDEX]}"

    if ! [ "$__RETURN_REF" -lt "$__RETURN_DEPTH" ] 2>/dev/null; then
      function returnRefUnset() {
        unset ${__RETURN_REFS[$__RETURN_INDEX]}
      }
      returnRefUnset
    fi
    __RETURN_REF="$__RETURN_VAL"
    let __RETURN_INDEX=__RETURN_INDEX+1
  done
  setTrap

  return 0
}

function declareDefault() {
  if [ -n "$__DEFERED_DECLARE" ]; then
    for statement in "${__DEFERED_DECLARE[@]:2}"; do
      if ! [[ "$statement" =~ ^- ]]; then
        declare -gn __REF_VAR="$statement"
        __REF_VAR="$1"
      fi
    done
    declare -g __DEFERED_DECLARE=

  fi
  if [[ "$2" == "declare" ]] && ! [[ "$*" =~ = ]]; then
    declare -g __DEFERED_DECLARE=("$@")
  fi
  return 0
}

function retTest() {
  hi='yo'
  echo 'in retTest'
  echo "${#FUNCNAME[@]}"
  declare retLen='qwe'
  echo $__REF_VAR
  declare retVal="Hello World"
  echo "retTest: retLen before return = $retLen"
  @return "$retLen" "$retVal" "asdf"  "asdfadfwer"
  echo "retTest: retLen after return = $retLen"
  return 0
}

function drtSep() {
  declare retLen val

  retTest retLen val val2
  @return "$retLen" "$val"
  return 0
}

function doRetTest() {
  echo 'in doRetTest'
  echo "${FUNCNAME[@]}"
  declare retLen val val2
  declare a wer ads=cxz wer
  declare awqer
  declare -i jasd
  echo "setting retLen to 'q'"
  retLen='q'
  # retTest retLen val val2
  drtSep retLen val val2
  echo "dRt retLen = $retLen"
  echo "dRT val $val"
  echo "dRT val2 $val2"
}

function setTrap() {
  trap DEBUG
}
function unsetTrap() {
  trap '' DEBUG
}
trap 'declareDefault "${#FUNCNAME[@]}" $BASH_COMMAND' DEBUG

# doRetTest
# echo "global retLen = $retLen"
# echo 'global val'
# echo $val
