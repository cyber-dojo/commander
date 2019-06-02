#!/bin/bash
set -e

# WIP

# Writes a new .env file (to stdout) with explicit SHAs tags for
# all service image names, ready to create a new commander image
# suitable for :latest tagging.
# Assumes a cyber-dojo server is up with a running container for
# each cyber-dojo-X service (X = web,nginx,ragger,runner, etc).
# And that these containes were launched from a
# cyberdojo/commander:latest image with a _plain_ .env file
# with each image-name untagged, eg
# CYBER_DOJO_RUNNER=cyberdojo/runner 

readonly MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"

. ${MY_DIR}/start-point-names.sh
. ${MY_DIR}/service-names.sh
. ${MY_DIR}/sha7_for.sh

env_var_for()
{
  name="${1}" # eg runner
  container="cyber-dojo-${name}"
  image_name=`docker inspect --format='{{.Config.Image}}' ${container} | xargs`
  sha=$(sha7_for ${name})
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
