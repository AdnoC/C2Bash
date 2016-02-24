#!/usr/bin/env bash
# source scanner/tokens.sh
include "$C2BASH_HOME"/helperlibs/queue.sh

include "$C2BASH_HOME"/scanner/tokens.sh

# Currently doesn't support multi-line comments

Queue tokenTypes
Queue tokenValues
Queue lineNumbers

# String::tokenName, String::tokenValue, Int::lineNumber
function addToken() {
  echo "adding token $1"
  Queue::push tokenTypes "$1"
  Queue::push tokenValues "$2"
  Queue::push lineNumbers "$3"
}

# String::line, Int::lineNum
function scanLine() {
  local line="$1"
  # echo "___________ $1 ___________"
  while [ "${#line}" -gt 0 ]; do
    declare -i longestLength=0
    declare longestMatch
    declare longestTokenName
    for tokenName in "${!__TOKEN_LITERAL[@]}"; do
      if [[ "$line" =~ ^(${__TOKEN_LITERAL[$tokenName]}) ]]; then
        # echo "$tokenName :: '${BASH_REMATCH[@]}'"
        if [ $longestLength -le "${#BASH_REMATCH[0]}" ]; then
          longestMatch="${BASH_REMATCH[0]}"
          longestLength="${#BASH_REMATCH[0]}"
          longestTokenName="$tokenName"
        fi
      fi
    done
    for tokenName in "${!__TOKEN_CONSTANT[@]}"; do
      if [[ "$line" =~ ^(${__TOKEN_CONSTANT[$tokenName]}) ]]; then
        # echo "$tokenName :: '${BASH_REMATCH[@]}'"
        if [ $longestLength -le "${#BASH_REMATCH[0]}" ]; then
          longestMatch="${BASH_REMATCH[0]}"
          longestLength="${#BASH_REMATCH[0]}"
          longestTokenName="$tokenName"
        fi
      fi
    done
    for tokenName in "${!__TOKEN_SYMBOL[@]}"; do
      if [[ "$line" =~ ^(${__TOKEN_SYMBOL[$tokenName]}) ]]; then
        # echo "$tokenName :: '${BASH_REMATCH[@]}'"
        if [ $longestLength -le "${#BASH_REMATCH[0]}" ]; then
          longestMatch="${BASH_REMATCH[0]}"
          longestLength="${#BASH_REMATCH[0]}"
          longestTokenName="$tokenName"
        fi
      fi
    done
    for tokenName in "${!__TOKEN_OPERATOR[@]}"; do
      if [[ "$line" =~ ^(${__TOKEN_OPERATOR[$tokenName]}) ]]; then
        # echo "$tokenName :: '${BASH_REMATCH[@]}'"
        if [ $longestLength -le "${#BASH_REMATCH[0]}" ]; then
          longestMatch="${BASH_REMATCH[0]}"
          longestLength="${#BASH_REMATCH[0]}"
          longestTokenName="$tokenName"
        fi
      fi
    done
    for tokenName in "${!__TOKEN_KEYWORD[@]}"; do
      if [[ "$line" =~ ^(${__TOKEN_KEYWORD[$tokenName]}) ]]; then
        # echo "$tokenName :: '${BASH_REMATCH[@]}'"
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
        # echo "line in next loop will be '$line'"
      else
        return 0
      fi
    else
      if [ "${#line}" -ne 0 ]; then
        echo $line
        # Parse error - we had something left over that couldn't be parsed.
        exit 1
      fi
    fi
  done
}

function scanFile() {
  # Bash/read handles concatenating lines ending with '/'
  declare lineNum=0
  while read p; do
    scanLine "$p" $lineNum
    # addToken "$T_LINE_END" " " "$lineNum"
    let lineNum=lineNum+1
  done < "$1"
  echo "Finished scanning"
  declare len
  declare tok
  declare val
  echo "${__queue0Value[@]}"
  while Queue::length len tokenTypes && [ $len -gt 0 ]; do
    Queue::pop tok tokenTypes
    Queue::pop val tokenValues
    echo "${__TOKEN_MAP[$tok]}  $val"
  done
}

scanFile "$1"
