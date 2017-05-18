#!/bin/bash

CMD='./cyber-dojo'

    LS="${CMD} start-point ls --quiet"
CREATE="${CMD} start-point create"
    RM="${CMD} start-point rm"
  DOWN="${CMD} down"
    UP="${CMD} up"

REPO='https://github.com/cyber-dojo/start-points'

if ${LS} | grep -q 'green_languages'; then
  echo "Switching from green to blue"
  # create blue new start-points
  echo "Creating languages"
  ${CREATE} blue_languages --git=${REPO}-languages
  echo "Creating exercises"
  ${CREATE} blue_exercises --git=${REPO}-exercises
  echo "Creating custom"
  ${CREATE} blue_custom    --git=${REPO}-custom
  # switch
  ${UP} --languages=blue_languages --exercises=blue_exercises --custom=blue_custom
  # delete green old start-points
  ${RM} green_languages &>/dev/null
  ${RM} green_exercises &>/dev/null
  ${RM} green_custom    &>/dev/null
else
  echo "Switching from blue to green"
  # create green new start-points
  echo "Creating languages"
  ${CREATE} green_languages --git=${REPO}-languages
  echo "Creating exercises"
  ${CREATE} green_exercises --git=${REPO}-exercises
  echo "Creating custom"
  ${CREATE} green_custom    --git=${REPO}-custom
  # switch
  ${UP} --languages=green_languages --exercises=green_exercises --custom=green_custom
  # delete blue old start-points
  ${RM} blue_languages &>/dev/null
  ${RM} blue_exercises &>/dev/null
  ${RM} blue_custom    &>/dev/null
fi
