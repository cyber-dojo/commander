#!/bin/bash

. ./cyber_dojo_helpers.sh

# can't remove start-point volumes in use
${exe} down >/dev/null 2>/dev/null
# remove default start-points for clean environment on start
currentStartPoints=`${exe} start-point ls --quiet`
defaultStartPoints=( "languages" "exercises" "custom" )
for defaultStartPoint in "${defaultStartPoints[@]}"
do
  if grep -q ${defaultStartPoint} <<< ${currentStartPoints}; then
    ${exe} start-point rm ${defaultStartPoint}
  fi
done
