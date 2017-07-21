#!/bin/bash
set -e

readonly CMD='./cyber-dojo'

readonly     LS="${CMD} start-point ls --quiet"
readonly CREATE="${CMD} start-point create"
readonly     RM="${CMD} start-point rm"
readonly     UP="${CMD} up"
readonly UPDATE="${CMD} update"

readonly REPO='https://github.com/cyber-dojo/start-points'

readonly LANGUAGE_LIST='https://raw.githubusercontent.com/cyber-dojo/start-points-languages/master/languages_list'
readonly EXERCISES_GIT=${REPO}-exercises
readonly CUSTOM_GIT=${REPO}-custom

# - - - - - - - - - - - - - - - - - - - - - - - - - - - -

echo "===Cleaning out old images/volumes/containers"
${CMD} clean

echo "===Updating server images"
${UPDATE} server

if ${LS} | grep -q 'green_languages'; then
  echo "===Switching from green to blue"
  echo "===Preparing new blue"
  echo "===Creating languages"
  ${CREATE} blue_languages --list=${LANGUAGE_LIST}
  echo "===Creating exercises"
  ${CREATE} blue_exercises --git=${EXERCISES_GIT}
  echo "===Creating custom"
  ${CREATE} blue_custom    --git=${CUSTOM_GIT}
  echo "===Switching to blue"
  ${UP} --languages=blue_languages --exercises=blue_exercises --custom=blue_custom
  echo "===Deleting old green"
  ${RM} green_languages &>/dev/null
  ${RM} green_exercises &>/dev/null
  ${RM} green_custom    &>/dev/null
else
  echo "===Switching from blue to green"
  echo "===Preparing new green"
  echo "===Creating languages"
  ${CREATE} green_languages --list=${LANGUAGE_LIST}
  echo "===Creating exercises"
  ${CREATE} green_exercises --git=${EXERCISES_GIT}
  echo "===Creating custom"
  ${CREATE} green_custom    --git=${CUSTOM_GIT}
  echo "===Switching to green"
  ${UP} --languages=green_languages --exercises=green_exercises --custom=green_custom
  echo "===Deleting old blue"
  ${RM} blue_languages &>/dev/null
  ${RM} blue_exercises &>/dev/null
  ${RM} blue_custom    &>/dev/null
fi
