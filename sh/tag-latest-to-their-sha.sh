#!/bin/bash
set -e

# after running pull-all-services-latest.sh
# run this to tag each latest to its sha
# which prevents further scripts from attempting
# to docker-pull them from dockerhub.

readonly MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"

. ${MY_DIR}/service-names.sh
. ${MY_DIR}/sha_for.sh

echo
for name in "${service_names[@]}"; do
  sha=$(sha_for ${name})
  tag=${sha:0:7}
  docker tag cyberdojo/${name}:latest cyberdojo/${name}:${tag}
done
