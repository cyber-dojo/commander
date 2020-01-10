#!/bin/bash -e

# Script to replace entries in start-point-create.sh
# Does not export any env-vars as they could be
# affected by existing exported env-vars.

readonly MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"
readonly ENV_VARS="$(docker run --rm cyberdojo/versioner:latest)"

SCRIPT=$(cat "${MY_DIR}/start-point-create.sh")

replace_in_script()
{
  local -r name="${1}"
  local -r env_var=$(echo "${ENV_VARS}" | grep "${name}")
  local -r value="${env_var:${#name}+1:999}"
  SCRIPT="${SCRIPT//${name}/${value}}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - -
replace_in_script CYBER_DOJO_START_POINTS_BASE_IMAGE
replace_in_script CYBER_DOJO_START_POINTS_BASE_TAG
replace_in_script CYBER_DOJO_CUSTOM_START_POINTS_PORT
replace_in_script CYBER_DOJO_EXERCISES_START_POINTS_PORT
replace_in_script CYBER_DOJO_LANGUAGES_START_POINTS_PORT

echo "${SCRIPT}"
