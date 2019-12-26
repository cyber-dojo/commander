#!/bin/bash
set -e

readonly MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"

# See cyber-dojo-inner extract_and_run()
readonly OVERRIDE_IMAGE="${CYBER_DOJO_START_POINTS_BASE_IMAGE}"
readonly OVERRIDE_TAG="${CYBER_DOJO_START_POINTS_BASE_TAG}"

readonly VERSIONER=cyberdojo/versioner:latest
export $(docker run --rm "${VERSIONER}" sh -c 'cat /app/.env')

if [ -n "${OVERRIDE_IMAGE}" ]; then
  export CYBER_DOJO_START_POINTS_BASE_IMAGE="${OVERRIDE_IMAGE}"
fi
if [ -n "${OVERRIDE_TAG}" ]; then
  export CYBER_DOJO_START_POINTS_BASE_TAG="${OVERRIDE_TAG}"
fi

SCRIPT=$(cat "${MY_DIR}/start-point-create.sh")

replace_in_script()
{
  local -r name="${1}"
  SCRIPT="${SCRIPT//${name}/${!name}}"
}

replace_in_script CYBER_DOJO_START_POINTS_BASE_IMAGE
replace_in_script CYBER_DOJO_START_POINTS_BASE_TAG
replace_in_script CYBER_DOJO_CUSTOM_START_POINTS_PORT
replace_in_script CYBER_DOJO_EXERCISES_START_POINTS_PORT
replace_in_script CYBER_DOJO_LANGUAGES_START_POINTS_PORT

echo "${SCRIPT}"
