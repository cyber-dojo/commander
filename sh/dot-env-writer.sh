#!/bin/bash
set -e

# WIP

readonly MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"

. ${MY_DIR}/service-names.sh
. ${MY_DIR}/sha_for.sh

echo CYBER_DOJO_PORT=80
echo

SHA=$(sha_for custom)
echo CYBER_DOJO_CUSTOM=cyberdojo/custom:${SHA:0:7}
SHA=$(sha_for exercises)
echo CYBER_DOJO_EXERCISES=cyberdojo/exercises:${SHA:0:7}
SHA=$(sha_for languages-common)
echo CYBER_DOJO_LANGUAGES=cyberdojo/languages-common:${SHA:0:7}

echo
for name in "${service_names[@]}"; do
  NAME=$(echo "${name}" | tr a-z\- A-Z\_)
  echo "CYBER_DOJO_${NAME}_SHA=$(sha_for ${name})"
done
