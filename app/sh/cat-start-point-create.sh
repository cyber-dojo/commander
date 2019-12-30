#!/bin/bash -e

readonly MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"

SCRIPT=$(cat "${MY_DIR}/start-point-create.sh")

replace_in_script()
{
  local -r name="${1}"
  SCRIPT="${SCRIPT//${name}/${!name}}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - -
versioner_env_vars()
{
  local -r versioner=cyberdojo/versioner:latest
  docker run --rm "${versioner}" sh -c 'cat /app/.env'
}

export $(versioner_env_vars)

# - - - - - - - - - - - - - - - - - - - - - - - - - - -
replace_in_script CYBER_DOJO_START_POINTS_BASE_IMAGE
replace_in_script CYBER_DOJO_START_POINTS_BASE_TAG
replace_in_script CYBER_DOJO_CUSTOM_START_POINTS_PORT
replace_in_script CYBER_DOJO_EXERCISES_START_POINTS_PORT
replace_in_script CYBER_DOJO_LANGUAGES_START_POINTS_PORT

echo "${SCRIPT}"
