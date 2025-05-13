#!/bin/bash -Eeu

# Script to replace entries in start-point-create.sh

readonly MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"
readonly ENV_VARS="$(docker run --entrypoint=cat --rm cyberdojo/versioner:latest /app/.env)"

SCRIPT=$(cat "${MY_DIR}/start-point-create.sh")

replace_in_script()
{
  local -r name="${1}"
  local -r versioner_env_var=$(echo "${ENV_VARS}" | grep "${name}")
  local -r versioner_value="${versioner_env_var:${#name}+1:999}"
  local -r env_var_value="${!name:-}"

  if [ -n "${env_var_value:-}" ]; then
    SCRIPT="${SCRIPT//${name}_REPLACED/${env_var_value}}"
  else
    SCRIPT="${SCRIPT//${name}_REPLACED/${versioner_value}}"
  fi
}

replace_in_script CYBER_DOJO_START_POINTS_BASE_IMAGE
replace_in_script CYBER_DOJO_START_POINTS_BASE_SHA
replace_in_script CYBER_DOJO_START_POINTS_BASE_TAG
replace_in_script CYBER_DOJO_START_POINTS_BASE_DIGEST

replace_in_script CYBER_DOJO_CUSTOM_START_POINTS_PORT
replace_in_script CYBER_DOJO_EXERCISES_START_POINTS_PORT
replace_in_script CYBER_DOJO_LANGUAGES_START_POINTS_PORT

SCRIPT="${SCRIPT//CYBER_DOJO_DEBUG_REPLACED/${CYBER_DOJO_DEBUG:-false}}"

echo "${SCRIPT}"
