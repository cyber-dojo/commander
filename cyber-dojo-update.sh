#!/bin/bash
set -e

handle_update_locally()
{
  if [ "$1" = '' ]; then
    replace_myself
  fi
  if [ "$1" = 'server' ] && [ "$2" = '' ]; then
    replace_myself
  fi
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

replace_myself()
{
  # See https://bani.com.br/2013/04/shell-script-that-updates-itself/
  local cid=$(docker create --interactive "${cyber_dojo_commander}" sh)
  docker cp "${cid}":/app/cyber-dojo /tmp
  docker rm "${cid}" > /dev/null
  local new_me=/tmp/cyber-dojo
  chmod +x "${new_me}"
  cp "${new_me}" "$0"
  rm "${new_me}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

shift # update
handle_update_locally "$@"
