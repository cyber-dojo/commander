#!/bin/bash
set -e

DOCKER_COMPOSE_VERSION=$1

if [ -z ${DOCKER_COMPOSE_VERSION} ]
then
  echo "Error: build.sh [DOCKER_COMPOSE_VERSION]."
  exit
fi

my_dir="$( cd "$( dirname "${0}" )" && pwd )"

context_dir=${my_dir}

docker build \
  --build-arg=DOCKER_COMPOSE_VERSION=${DOCKER_COMPOSE_VERSION} \
  --tag=cyberdojo/commander \
  --file=${context_dir}/Dockerfile \
  ${context_dir}

