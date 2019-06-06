#!/bin/bash
set -e
shift # sh

# - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# $ ./cyber-dojo sh [NAME]
# - - - - - - - - - - - - - - - - - - - - - - - - - - - -

show_help()
{
  echo
  echo Use: cyber-dojo sh SERVICE
  echo
  echo Shells into a service container
  echo Example: cyber-dojo sh web
  echo Example: cyber-dojo sh runner
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

error()
{
  >&2 echo "ERROR: ${2}"
  exit "${1}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

shell_in()
{
  local arg="$1"
  local name="cyber-dojo-${arg}"
  if running_container "${name}"; then
    echo "shelling into ${name}"
    local cmd="export PS1='[${arg}] \\w $ ';sh"
    docker exec --interactive --tty "${name}" sh -c "${cmd}"
  elif [ "${arg}" != '--help' ] && [ "${arg}" != '-h' ] && [ "${arg}" != '' ]; then
    error 4 "${name} is not a running container"
  fi
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

running_container()
{
  local space='\s'
  local name="$1"
  local end_of_line='$'
  docker ps --filter "name=${name}" | grep "${space}${name}${end_of_line}" > /dev/null
  return $?
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

if [ -z "$1" ] || [ "$1" = '-h' ] || [ "$1" = '--help' ]; then
  show_help
elif [ -n "$2" ]; then
  show_help
  exit 1
else
  shell_in "$1"
fi
