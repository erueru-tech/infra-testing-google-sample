#!/bin/bash

function join() {
  local IFS="$1"
  shift
  for str in "$@"; do
    if [ -n "$str" ]; then
      arr+=("$str")
    fi
  done
  echo "${arr[*]}"
}
