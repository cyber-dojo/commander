#!/bin/sh

readonly MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"

if [ -z "${DOCKER_MACHINE_NAME}" ]; then
  echo "Use this script in a Docker-Toolbox Quickstart Terminal."
  echo "ERROR: DOCKER_MACHINE_NAME is not set..."
  exit 1
fi

docker-machine ssh "${DOCKER_MACHINE_NAME}" test -e ./cyber-dojo 2> /dev/null
if [ $? != 0 ]; then
  # echo "./cyber-dojo does not exit on ${DOCKER_MACHINE_NAME} VM"
  # echo "Copying it now..."
  docker-machine scp --quiet "${MY_DIR}/cyber-dojo" "${DOCKER_MACHINE_NAME}:."
fi

docker-machine ssh "${DOCKER_MACHINE_NAME}" ./cyber-dojo ${@}
