#!/bin/bash
set -e

# WIP

# Assumes a cyber-dojo server is up with a running container for
# each cyber-dojo-X service (X = web,nginx,ragger,runner, etc).
# And that these containes were launched from a
# cyberdojo/commander:latest image with a :latest .env file
# with each image-name tagged with :latest
# CYBER_DOJO_RUNNER_TAG=latest

readonly MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"

. ${MY_DIR}/service-names.sh
. ${MY_DIR}/sha_for.sh

sha_env_var_for()
{
  name="${1}" # eg runner
  NAME=$(echo "${name}" | tr a-z A-Z)
  echo "CYBER_DOJO_${NAME}_SHA=$(sha_for ${name})"
}

echo
for name in "${service_names[@]}"; do
  echo "$(sha_env_var_for ${name})"
done
