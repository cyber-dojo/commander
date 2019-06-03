#!/bin/bash
set -e
shift # sh

# - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# $ ./cyber-dojo sh ...
# - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# The docker run command could take --interactive --tty
# options which should enable the sh command to be handled
# by the commander container. Trying this out briefly shows
# that it affects the captured output (trailing \r \n) which
# breaks the sh tests.
# - - - - - - - - - - - - - - - - - - - - - - - - - - - -

error()
{
  >&2 echo "ERROR: ${2}"
  exit "${1}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

handle_sh_locally()
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

handle_sh_locally "$@"
