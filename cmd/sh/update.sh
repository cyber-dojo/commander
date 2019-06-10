#!/bin/bash
set -e
shift # update
readonly TAG="${1:-latest}"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#  cyber-dojo update [latest|TAG]
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

show_help()
{
  echo
  echo 'Use: cyber-dojo update [latest|TAG]'
  echo
  echo Updates all cyber-dojo server images and the cyber-dojo script file
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

error_bad_args()
{
  for arg in "$@"
  do
    >&2 echo "ERROR: unknown argument [${arg}]"
  done
  exit 1
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

if [ "$1" = '-h' ] || [ "$1" = '--help' ]; then
  show_help
else
  docker pull cyberdojo/versioner:${TAG}
  docker tag cyberdojo/versioner:${TAG} cyberdojo/versioner:latest
  #TODO: if TAG=latest tag create release tag
  #error_bad_args "$@"
fi
