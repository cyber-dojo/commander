#!/bin/bash
set -e
shift # update

readonly TAG="${1:-latest}"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#  ./cyber-dojo update [latest|TAG]
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

replace_main_script()
{
  # See https://bani.com.br/2013/04/shell-script-that-updates-itself/
  local cid=$(docker create --interactive "$(commander_image_name)" sh)
  docker cp "${cid}":/app/cyber-dojo /tmp
  docker rm "${cid}" > /dev/null
  #TODO: pass in the dir of the main script?
  #local new_me=/tmp/cyber-dojo
  #chmod +x "${new_me}"
  #cp "${new_me}" "$0"
  #rm "${new_me}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

commander_image_name()
{
  local readonly VERSIONER=cyberdojo/versioner:latest
  local readonly ENV_VARS=$(docker run --rm ${VERSIONER} sh -c 'cat /app/.env')
  local readonly COMMANDER_VAR=$(echo "${ENV_VARS}" | grep 'CYBER_DOJO_COMMANDER_SHA')
  local readonly COMMANDER_SHA=$(echo ${COMMANDER_VAR:25:99})
  echo "cyberdojo/commander:${COMMANDER_SHA:0:7}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

if [ "$1" = '-h' ] || [ "$1" = '--help' ]; then
  show_help
else
  docker pull cyberdojo/versioner:${TAG}
  docker tag cyberdojo/versioner:${TAG} cyberdojo/versioner:latest
  docker tag cyberdojo/versioner:${TAG} cyberdojo/versioner:${TAG}
  replace_main_script
#  error_bad_args "$@"
fi
