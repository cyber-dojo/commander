#!/bin/bash

readonly MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"

readonly OVERRIDE_CYBER_DOJO_STARTER_BASE_TAG=${CYBER_DOJO_STARTER_BASE_TAG}

VERSIONER=cyberdojo/versioner:latest
export $(docker run --rm ${VERSIONER} sh -c 'cat /app/.env')

CYBER_DOJO_STARTER_BASE_TAG=${OVERRIDE_CYBER_DOJO_STARTER_BASE_TAG:-${CYBER_DOJO_STARTER_BASE_TAG}}

SCRIPT=$(cat "${MY_DIR}/start-point-create.sh")

echo "${SCRIPT//CYBER_DOJO_STARTER_BASE_TAG/${CYBER_DOJO_STARTER_BASE_TAG}}"
