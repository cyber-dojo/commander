#!/bin/bash
set -e

MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"
. ${MY_DIR}/rm_default_start_points.sh

#for file in ${MY_DIR}/test_*.sh; do
#  ${file}
#done

${MY_DIR}/test_cyber_dojo.sh
${MY_DIR}/test_down.sh
