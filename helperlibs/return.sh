#!/usr/bin/env bash

declare -g __DEFERRED_DECLARE
# Pass debug taps to functions. Means you don't have to make the trap in every function.
set -o functrace

# Allows alias expansion in non-interactive shells.
shopt -s expand_aliases
# Alias lets you implicitly pass "$*"
alias @return='@return "$*" '

# Helper function that lets you unset and remove the local scope of a variable, even
# one that was made local in the caller function.
function declaredRefUnset() {
  unset "$1"
}

# This function is a lot more complex than it needs to be in order to make sure
# that it can return to a pointer with the same name as a variable it uses.
# Pass __RETURN_REFS with a quoted $*
# String::__RETURN_REFS, ...String::value
function @return() {
  # Disable the debug trap for this function
  trap '' DEBUG

  declare __RETURN_DEPTH="${#FUNCNAME[@]}"
  let __RETURN_DEPTH=__RETURN_DEPTH-1
  declare -a __RETURN_REFS=($1)
  shift
  declare __RETURN_REF
  declare __RETURN_INDEX=0
  declare __RETURN_VAL
  for __RETURN_VAL in "$@"; do
    if [ "${#__RETURN_REFS[@]}" -le "$__RETURN_INDEX" ]; then
      >&2 echo "Tried to return more values than pointers were given"
      break;
    fi

    if [[ "${__RETURN_REFS[$__RETURN_INDEX]}" != "__RETURN_REF" ]]; then
      declare -n __RETURN_REF="${__RETURN_REFS[$__RETURN_INDEX]}"

      if [[ "${__RETURN_REFS[$__RETURN_INDEX]}" == "__RETURN_DEPTH" ]]; then
        declare tmp="$__RETURN_DEPTH"
        declaredRefUnset __RETURN_DEPTH
      else 
        if [[ "${__RETURN_REFS[$__RETURN_INDEX]}" == "__RETURN_REFS" ]]; then
          declare tmp="$__RETURN_REFS"
          declaredRefUnset __RETURN_REFS
        else 
          if [[ "${__RETURN_REFS[$__RETURN_INDEX]}" == "__RETURN_INDEX" ]]; then
            declare tmp="$__RETURN_INDEX"
            declaredRefUnset __RETURN_INDEX
          fi
        fi

        if ! [ "$__RETURN_REF" -lt "$__RETURN_DEPTH" ] 2>/dev/null; then
          declaredRefUnset "${__RETURN_REFS[$__RETURN_INDEX]}"
        fi
      fi

      __RETURN_REF="$__RETURN_VAL"

      if [ -n "$tmp" ]; then
        if [[ "${__RETURN_REFS[$tmp]}" == "__RETURN_INDEX" ]]; then
          declare __RETURN_INDEX=$tmp
          declaredRefUnset tmp
        else 
          if [[ "${tmp[$__RETURN_INDEX]}" == "__RETURN_REFS" ]]; then
            declare -a __RETURN_REFS="$tmp"
            declaredRefUnset tmp
          else 
            if [[ "${__RETURN_REFS[$__RETURN_INDEX]}" == "__RETURN_DEPTH" ]]; then
              declare __RETURN_DEPTH="$tmp"
              declaredRefUnset tmp
            fi
          fi
        fi
      fi
    else
      if [[ "${__RETURN_REFS[$__RETURN_INDEX]}" == "__RETURN_VAL" ]]; then
        declare -n __RETURN_REF="${__RETURN_REFS[$__RETURN_INDEX]}"
        declare tmp="$__RETURN_VAL"
        declaredRefUnset __RETURN_VAL
        __RETURN_REF="$tmp"
        declaredRefUnset tmp
        declare __RETURN_VAL
      else
        declaredRefUnset __RETURN_REF
        declare -n tmp="__RETURN_REF"
        tmp="$__RETURN_VAL"
        declaredRefUnset tmp
      fi
    fi


    let __RETURN_INDEX=__RETURN_INDEX+1
  done

  # Re-enable the debug trap
  trap DEBUG

  return 0
}

# Initializes uninitialized declared variables to the depth of the function they were declared in
# Int::functionDepth, ...String::bashCommand
function declareDefault() {
  if [ -n "$__DEFERRED_DECLARE" ]; then
    declare __DECLARED_VAR
    for __DECLARED_VAR in "${__DEFERRED_DECLARE[@]:2}"; do
      # Skip any arguments passed to declare
      if ! [[ "$__DECLARED_VAR" =~ ^- ]]; then

        if [[ "$__DECLARED_VAR" != "__REF_VAR" ]]; then
          declare -n __REF_VAR="$__DECLARED_VAR"

          # Handle the declared var having the same name as one used in the function
          if [[ "$__DECLARED_VAR" == "__DECLARED_VAR" ]]; then
            declaredRefUnset __DECLARED_VAR
          fi

          __REF_VAR="$1"
        # Handle the declared var having the same name as one used in the function
        else
          declaredRefUnset __REF_VAR

          declare -n tmp="__REF_VAR"
          tmp="$1"

          declaredRefUnset tmp
        fi
      fi
    done

    # unset __DEFERRED_DECLARE so that we don't process the same command over and over
    declare -g __DEFERRED_DECLARE=
  fi

  # If the command was to declare vars and it didn't initialize any of them, defer initialization until the next line.
  # This makes sure that we wait until the variable was actually declared and local before we initialize it.
  # Also skip if we are declaring a global variable.
  if [[ "$2" == "declare" ]] && ! [[ "$*" =~ = ]] && ! [[ "$*" =~ -[^[:space:]]*g ]]; then
    echo 'deferring declare'
    declare -g __DEFERRED_DECLARE=("$@")
  else
    echo 'not deferring'
  fi
  return 0
}

# trap 'declareDefault "${#FUNCNAME[@]}" $BASH_COMMAND' DEBUG
