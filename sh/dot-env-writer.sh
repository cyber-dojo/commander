#!/bin/bash
set -e

# WIP

# Writes a new .env file (to stdout) with explicit SHAs tags for
# all service image names, ready to create a new commander image
# suitable for :latest tagging.

readonly MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"

. ${MY_DIR}/start-point-names.sh
. ${MY_DIR}/service-names.sh

env_var_for()
{
  name="${1}"
  container="cyber-dojo-${name}"
  image_name=`docker inspect --format='{{.Config.Image}}' ${container} | xargs`
  sha=`docker exec -i ${container} sh -c  'echo -n ${SHA}' | xargs`
  NAME=$(echo "${name}" | tr a-z A-Z)
  echo "CYBER_DOJO_${NAME}=${image_name}:${sha:0:7}"
}

echo
echo CYBER_DOJO_PORT=80
echo
for name in "${start_point_names[@]}"; do
  echo "$(env_var_for ${name})"
done
echo
for name in "${service_names[@]}"; do
  echo "$(env_var_for ${name})"
done
