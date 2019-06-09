#!/bin/bash

MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"
. ${MY_DIR}/cyber_dojo_helpers.sh

# can't remove start-point volumes in use
${exe} down >/dev/null 2>/dev/null

# remove default start-points for clean environment on start
currentStartPoints=`${exe} start-point ls --quiet`
defaultStartPoints=( "cyberdojo/languages-common:latest" "cyberdojo/exercises:latest" "cyberdojo/custom:latest" )
for defaultStartPoint in "${defaultStartPoints[@]}"
do
  if grep -q ${defaultStartPoint} <<< ${currentStartPoints}; then
    : #${exe} start-point rm ${defaultStartPoint}
  fi
done
