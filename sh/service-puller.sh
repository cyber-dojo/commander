#!/bin/bash
set -e

# WIP

readonly MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"

. ${MY_DIR}/start-point-names.sh
. ${MY_DIR}/service-names.sh

for name in "${start_point_names[@]}"; do
  docker pull cyberdojo/${name}:latest
done

for name in "${service_names[@]}"; do
  docker pull cyberdojo/${name}:latest
done
