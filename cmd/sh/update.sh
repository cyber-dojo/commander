#!/bin/bash
set -e
shift # update

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#  ./cyber-dojo update
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

show_help()
{
  echo
  echo "Use: cyber-dojo update"
  echo
  echo 'Updates all cyber-dojo server images and the cyber-dojo script file'
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

handle_update_locally()
{
  if [ "$1" = '-h' ] || [ "$1" = '--help' ]; then
    show_help
  elif [ "$1" = '' ]; then
    # TODO: THE UPDATE...
    replace_myself
  else
    error_bad_args "$@"
  fi
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

handle_update_locally "$@"
