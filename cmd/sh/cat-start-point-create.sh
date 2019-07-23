#!/bin/bash

readonly MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"

if [ -z "${STARTER_BASE_TAG}" ]; then
  VERSIONER=cyberdojo/versioner:latest
  ENV_VARS=$(docker run --rm ${VERSIONER} sh -c 'cat /app/.env')
  ENV_VAR=$(echo "${ENV_VARS}" | grep 'CYBER_DOJO_STARTER_BASE_SHA')
  # CYBER_DOJO_STARTER_BASE_SHA is 27 chars long
  # +1 for the = in VAR=VALUE makes 28
  STARTER_BASE_SHA=$(echo ${ENV_VAR:28:99})
  STARTER_BASE_TAG=${STARTER_BASE_SHA:0:7}
fi

SCRIPT=$(cat "${MY_DIR}/start-point-create.sh")

# replace the string STARTER_BASE_TAG with its var-value in SCRIPT
echo "${SCRIPT//STARTER_BASE_TAG/${STARTER_BASE_TAG}}"
