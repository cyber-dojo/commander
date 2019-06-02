#!/bin/bash
set -e

sha7_for()
{
  local name="${1}" # eg runner
  local container="cyber-dojo-${name}"
  # xargs is to strip whitespace
  local sha=`docker exec -i ${container} sh -c  'echo -n ${SHA}' | xargs`
  echo "${sha:0:7}"
}

if [ "${1}" != '' ]; then
  sha7_for "${1}"
fi
