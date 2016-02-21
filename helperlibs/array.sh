#!/usr/bin/env bash
declare -gi NOT_IN_ARRAY=243

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
