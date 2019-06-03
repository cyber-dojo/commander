#!/bin/bash
set -e

readonly MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"

. ${MY_DIR}/service-names.sh
. ${MY_DIR}/sha_for.sh

echo
for name in "${service_names[@]}"; do
  sha=$(sha_for ${name})
  tag=${sha:0:7}
  docker tag cyberdojo/${name}:latest cyberdojo/${name}:${tag}
done
