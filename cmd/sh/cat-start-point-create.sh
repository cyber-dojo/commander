#!/bin/bash

readonly MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"

VERSIONER=cyberdojo/versioner:latest

# Local integration tests sometimes append an env-var to
# versioner's .env file, eg
# CYBER_DOJO_WEB_SHA=26a951fe383b60efad961e1acbbb6094a048bebb
# and then build a local cyberdojo/versioner:latest image.
# For this to work, the grep below has to get the _last_
# matching entry, hence the tac instead of cat.
ENV_VARS=$(docker run --rm ${VERSIONER} sh -c 'tac /app/.env')
ENV_VAR=$(echo "${ENV_VARS}" | grep 'CYBER_DOJO_STARTER_BASE_SHA')

# CYBER_DOJO_STARTER_BASE_SHA is 27 chars long
# +1 for the = in VAR=VALUE
STARTER_BASE_SHA=$(echo ${ENV_VAR:28:99})
STARTER_BASE_TAG=${STARTER_BASE_SHA:0:7}
SCRIPT=$(cat "${MY_DIR}/start-point-create.sh")

# replace the string STARTER_BASE_TAG with its var-value in SCRIPT
echo "${SCRIPT//STARTER_BASE_TAG/${STARTER_BASE_TAG}}"
