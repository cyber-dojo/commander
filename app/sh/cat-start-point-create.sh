#!/bin/bash -Eeu

# Script to replace entries in start-point-create.sh
# Does not export any env-vars as they could be
# affected by existing exported env-vars.

readonly MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"
readonly ENV_VARS="$(docker run --entrypoint=cat --rm cyberdojo/versioner:latest /app/.env)"

SCRIPT=$(cat "${MY_DIR}/start-point-create.sh")

replace_in_script()
{
  local -r name="${1}"
  local -r env_var=$(echo "${ENV_VARS}" | grep "${name}")
  local -r value="${env_var:${#name}+1:999}"
  SCRIPT="${SCRIPT//${name}/${value}}"
}

replace_in_script_via_explicit_env_var()
{
  local -r name="${1}"
  local -r value="${2}"
  SCRIPT="${SCRIPT//${name}/${value}}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - -
replace_in_script CYBER_DOJO_START_POINTS_BASE_IMAGE
# The start-points-base workflow trigger the downstream workflows of the three X-start-points
# so they each pass the new base-image as an env-var to commander
if [ -z "${CYBER_DOJO_START_POINTS_BASE_TAG:-}" ]; then
  replace_in_script CYBER_DOJO_START_POINTS_BASE_TAG
else
  replace_in_script_via_explicit_env_var CYBER_DOJO_START_POINTS_BASE_TAG "${CYBER_DOJO_START_POINTS_BASE_TAG}"
fi

replace_in_script_via_explicit_env_var CYBER_DOJO_DEBUG "${CYBER_DOJO_DEBUG:-false}"

# Note: Can't add CYBER_DOJO_START_POINTS_BASE_DIGEST as it breaks start-points-base tests
#replace_in_script CYBER_DOJO_START_POINTS_BASE_DIGEST

replace_in_script CYBER_DOJO_CUSTOM_START_POINTS_PORT
replace_in_script CYBER_DOJO_EXERCISES_START_POINTS_PORT
replace_in_script CYBER_DOJO_LANGUAGES_START_POINTS_PORT

echo "${SCRIPT}"
