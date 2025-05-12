#!/bin/bash -Eeu

# Script to replace entries in start-point-create.sh
# Does not export any env-vars as they could be
# affected by existing exported env-vars.

readonly MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"
readonly ENV_VARS="$(docker run --entrypoint=cat --rm cyberdojo/versioner:latest /app/.env)"

SCRIPT=$(cat "${MY_DIR}/start-point-create.sh")

replace_in_script_via_versioner()
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
replace_in_script_via_versioner CYBER_DOJO_START_POINTS_BASE_IMAGE
# The start-points-base workflow triggers the downstream workflows of the three X-start-points
# where they each pass their base-image env-vars to commander

if [ -z "${CYBER_DOJO_START_POINTS_BASE_IMAGE:-}" ]; then
  replace_in_script_via_versioner CYBER_DOJO_START_POINTS_BASE_IMAGE
else
  replace_in_script_via_explicit_env_var CYBER_DOJO_START_POINTS_BASE_IMAGE "${CYBER_DOJO_START_POINTS_BASE_IMAGE}"
fi

if [ -z "${CYBER_DOJO_START_POINTS_BASE_SHA:-}" ]; then
  replace_in_script_via_versioner CYBER_DOJO_START_POINTS_BASE_SHA
else
  replace_in_script_via_explicit_env_var CYBER_DOJO_START_POINTS_BASE_SHA "${CYBER_DOJO_START_POINTS_BASE_SHA}"
fi

if [ -z "${CYBER_DOJO_START_POINTS_BASE_TAG:-}" ]; then
  replace_in_script_via_versioner CYBER_DOJO_START_POINTS_BASE_TAG
else
  replace_in_script_via_explicit_env_var CYBER_DOJO_START_POINTS_BASE_TAG "${CYBER_DOJO_START_POINTS_BASE_TAG}"
fi

if [ -z "${CYBER_DOJO_START_POINTS_BASE_DIGEST:-}" ]; then
  replace_in_script_via_versioner CYBER_DOJO_START_POINTS_BASE_DIGEST
else
  replace_in_script_via_explicit_env_var CYBER_DOJO_START_POINTS_BASE_DIGEST "${CYBER_DOJO_START_POINTS_BASE_DIGEST}"
fi

replace_in_script_via_explicit_env_var CYBER_DOJO_DEBUG "${CYBER_DOJO_DEBUG:-false}"

replace_in_script_via_versioner CYBER_DOJO_CUSTOM_START_POINTS_PORT
replace_in_script_via_versioner CYBER_DOJO_EXERCISES_START_POINTS_PORT
replace_in_script_via_versioner CYBER_DOJO_LANGUAGES_START_POINTS_PORT

echo "${SCRIPT}"
