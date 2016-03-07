#!/usr/bin/env bash
# source scanner/tokens.sh
include "$C2BASH_HOME"/helperlibs/queue.sh
include "$C2BASH_HOME"/scanner/tokens.sh
include "$C2BASH_HOME"/helperlibs/array.sh
if [ -n "$__DEBUG" ]; then
  include "$C2BASH_HOME"/helperlibs/io.sh
fi

# Currently doesn't support multi-line comments


# String::tokenName, String::tokenValue, Int::lineNumber
function addToken() {
  Queue::push tokenTypes "$1"
  Queue::push tokenValues "$2"
  Queue::push lineNumbers "$3"
  return 0
}

# String::line, Int::lineNum
function scanLine() {
  local line="$1"
  while [ "${#line}" -gt 0 ]; do
    declare -i longestLength=0
    declare longestMatch
    declare longestTokenName
    for tokenName in "${!__TOKEN_LITERAL[@]}"; do
      if [[ "$line" =~ ^(${__TOKEN_LITERAL[$tokenName]}) ]]; then
        if [ $longestLength -le "${#BASH_REMATCH[0]}" ]; then
          longestMatch="${BASH_REMATCH[0]}"
          longestLength="${#BASH_REMATCH[0]}"
          longestTokenName="$tokenName"
        fi
      fi
    done
    for tokenName in "${!__TOKEN_CONSTANT[@]}"; do
      if [[ "$line" =~ ^(${__TOKEN_CONSTANT[$tokenName]}) ]]; then
        if [ $longestLength -le "${#BASH_REMATCH[0]}" ]; then
          longestMatch="${BASH_REMATCH[0]}"
          longestLength="${#BASH_REMATCH[0]}"
          longestTokenName="$tokenName"
        fi
      fi
    done
    for tokenName in "${!__TOKEN_SYMBOL[@]}"; do
      if [[ "$line" =~ ^(${__TOKEN_SYMBOL[$tokenName]}) ]]; then
        if [ $longestLength -le "${#BASH_REMATCH[0]}" ]; then
          longestMatch="${BASH_REMATCH[0]}"
          longestLength="${#BASH_REMATCH[0]}"
          longestTokenName="$tokenName"
        fi
      fi
    done
    for tokenName in "${!__TOKEN_OPERATOR[@]}"; do
      if [[ "$line" =~ ^(${__TOKEN_OPERATOR[$tokenName]}) ]]; then
        if [ $longestLength -le "${#BASH_REMATCH[0]}" ]; then
          longestMatch="${BASH_REMATCH[0]}"
          longestLength="${#BASH_REMATCH[0]}"
          longestTokenName="$tokenName"
        fi
      fi
    done
    for tokenName in "${!__TOKEN_KEYWORD[@]}"; do
      if [[ "$line" =~ ^(${__TOKEN_KEYWORD[$tokenName]}) ]]; then
        if [ $longestLength -le "${#BASH_REMATCH[0]}" ]; then
          longestMatch="${BASH_REMATCH[0]}"
          longestLength="${#BASH_REMATCH[0]}"
          longestTokenName="$tokenName"
        fi
      fi
    done
    if [ $longestLength -ne 0 ]; then
      addToken "$longestTokenName" "$longestMatch" "$2"
      if [ "${#line}" -gt "$longestLength" ]; then
        line="${line:$longestLength}"
      else
        return 0
      fi
    else
      if [ "${#line}" -ne 0 ]; then
        if [ -n "$__DEBUG" ]; then
          echoerr "Found an error while scanning line $line"
        fi
        # Parse error - we had something left over that couldn't be parsed.
        exit 1
      fi
    fi
  done
}

# Pointer::tokenTypeQueue, Pointer::tokenValueQueue, Pointer::tokenLineNumber, String::file
function scanFile() {
  declare tokenTypes tokenValues lineNumbers
  Queue tokenTypes
  Queue tokenValues
  Queue lineNumbers

  # Bash/read handles concatenating lines ending with '/'
  declare lineNum=0
  while read p; do
    scanLine "$p" $lineNum
    # addToken "$T_LINE_END" " " "$lineNum"
    let lineNum=lineNum+1
  done < "$4"

  if [ -n "$__DEBUG" ]; then
    declare len
    declare tok
    declare val
    declare keys
    Array::keys keys tokenTypes
    declare tokName
    for key in $keys; do
      Array::get tok tokenTypes "$key"
      Array::get val tokenValues "$key"
      Array::get tokName __TOKEN_MAP $tok
      echotab "$tokName -> $val"
    done
  fi

  @return "$tokenTypes" "$tokenValues" "$lineNumbers"
  return 0
}

if [ "${#FUNCNAME[@]}" -eq "0" ]; then
  if [ -n "$__DEBUG" ]; then
    echotab "Scanning File"
  fi
  declare -g tokenTypes tokenValues lineNumbers
  scanFile tokenTypes tokenValues lineNumbers "$1"
  if [ -n "$__DEBUG" ]; then
    echotab "Finished scanning"
  fi
fi
