#!/usr/bin/env bash
# Prevent this from being sourced multiple times
if [ -n "$__SOURCE_UNGAURDED" ]; then
  return 0
fi
declare -g __SOURCE_UNGAURDED=true

declare -ga __SOURCED_FILES=()

# Gets a path relative to another (in this case, $C2BASH_HOME).
# Thank you http://stackoverflow.com/a/12498485
# Pointer::RelativePath, AbsolurePath
function getRelPath() {
  declare -n result=$1

  # both $1 and $2 are absolute paths beginning with /
  # returns relative path to $2/$target from $1/$source
  local source=$C2BASH_HOME
  local target=$2

  local common_part=$source # for now
  local forward_part

  while [[ "${target#$common_part}" == "${target}" ]]; do
      # no match, means that candidate common part is not correct
      # go up one level (reduce common part)
      common_part="$(dirname $common_part)"
      # and record that we went back, with correct / handling
      if [[ -z $result ]]; then
          result=".."
      else
          result="../$result"
      fi
  done

  if [[ $common_part == "/" ]]; then
      # special case for root (no common path)
      result="$result/"
  fi

  # since we now have identified the common part,
  # compute the non-common part
  forward_part="${target#$common_part}"

  # and now stick all parts together
  if [[ -n $result ]] && [[ -n $forward_part ]]; then
      result="$result$forward_part"
  elif [[ -n $forward_part ]]; then
      # extra slash removal
      result="${forward_part:1}"
  fi
  
  # Handle the case where source==target
  if [[ -z $result ]]; then
    result="."
  fi
}

# Sources files and makes sure not to source a file twice to make sure there aren't any source loops
# BashScriptFile
function include() {
  # Get the absolute path of the file.
  local file="$(cd "$(dirname $1)"; pwd -P)"
  file="$file/$(basename $1)"

  for sourced in "${__SOURCED_FILES[@]}"; do
    # If we already sourced the file, don't do it again.
    if [[ "$file" == "$sourced" ]]; then
      return 0
    fi
  done
  # If we made it here we haven't sourced it yet, so source it.
  source "$file"
  __SOURCED_FILES+="$file"
}
