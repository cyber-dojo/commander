#!/bin/sh
set -e

readonly CMD='./cyber-dojo'

readonly     LS="${CMD} start-point ls --quiet"
readonly CREATE="${CMD} start-point create"
readonly     RM="${CMD} start-point rm"
readonly LATEST="${CMD} start-point latest"
readonly     UP="${CMD} up"
readonly UPDATE="${CMD} update"

readonly REPO='https://github.com/cyber-dojo/start-points'

readonly LANGUAGE_LIST='https://raw.githubusercontent.com/cyber-dojo/start-points-languages/master/languages_list'
readonly EXERCISES_GIT=${REPO}-exercises
readonly CUSTOM_GIT=${REPO}-custom

# - - - - - - - - - - - - - - - - - - - - - - - - - - - -

from_to()
{
  readonly from=$1
  readonly to=$2
  echo "===Switching from ${from} to ${to}"
  echo "===Preparing new ${to}"
  echo "===Creating ${to} languages"
  ${CREATE} ${to}_languages --list=${LANGUAGE_LIST}
  echo "===Creating ${to} exercises"
  ${CREATE} ${to}_exercises --git=${EXERCISES_GIT}
  echo "===Creating ${to} custom"
  ${CREATE} ${to}_custom    --git=${CUSTOM_GIT}
  echo "===Getting latest ${to} test-framework language images"
  ${LATEST} ${to}_languages
  echo "===Getting latest ${to} test-framework custom images"
  ${LATEST} ${to}_custom
  echo "===Switching to ${to}"
  ${UP} --languages=${to}_languages --exercises=${to}_exercises --custom=${to}_custom
  echo "===Deleting old ${from}"
  ${RM} ${from}_languages &>/dev/null
  ${RM} ${from}_exercises &>/dev/null
  ${RM} ${from}_custom    &>/dev/null
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - -

echo "===Cleaning out old images/volumes/containers"
${CMD} clean
echo "===Updating server images"
${UPDATE} server

if ${LS} | grep -q 'green_languages'; then
  from_to 'green' 'blue'
else
  from_to 'blue' 'green'
fi
