#!/bin/bash

# Parameters come from cyberdojo/versioner:latest's .env file
# They can be overriden with environment-variables.
# See cyber-dojo-inner extract_and_run()

readonly MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"

readonly OVERRIDE_CYBER_DOJO_START_POINTS_BASE_IMAGE=${CYBER_DOJO_START_POINTS_BASE_IMAGE}
readonly OVERRIDE_CYBER_DOJO_START_POINTS_BASE_TAG=${CYBER_DOJO_START_POINTS_BASE_TAG}
VERSIONER=cyberdojo/versioner:latest
export $(docker run --rm ${VERSIONER} sh -c 'cat /app/.env')

CYBER_DOJO_START_POINTS_BASE_IMAGE=${OVERRIDE_CYBER_DOJO_START_POINTS_BASE_IMAGE:-${CYBER_DOJO_START_POINTS_BASE_IMAGE}}
CYBER_DOJO_START_POINTS_BASE_TAG=${OVERRIDE_CYBER_DOJO_START_POINTS_BASE_TAG:-${CYBER_DOJO_START_POINTS_BASE_TAG}}

SCRIPT=$(cat "${MY_DIR}/start-point-create.sh")
SCRIPT="${SCRIPT//CYBER_DOJO_START_POINTS_BASE_IMAGE/${CYBER_DOJO_START_POINTS_BASE_IMAGE}}"
SCRIPT="${SCRIPT//CYBER_DOJO_START_POINTS_BASE_TAG/${CYBER_DOJO_START_POINTS_BASE_TAG}}"
echo "${SCRIPT}"
