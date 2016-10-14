#!/bin/sh
set -e

docker_version=${1:-1.12.2}
docker_compose_version=${2:-1.8.1}

my_dir="$( cd "$( dirname "${0}" )" && pwd )"

context_dir=.

docker build \
  --build-arg=DOCKER_VERSION=${docker_version} \
  --build-arg=DOCKER_COMPOSE_VERSION=${docker_compose_version} \
  --tag=cyberdojo/${PWD##*/}:${docker_version} \
  --file=${context_dir}/Dockerfile \
  ${context_dir}

