#!/bin/bash
set -e

readonly ROOT_DIR="$( cd "$( dirname "${0}" )" && cd .. && pwd )"
readonly SHA=$(cd "${ROOT_DIR}" && git rev-parse HEAD)

docker build \
  --build-arg SHA="${SHA}" \
  --file="${ROOT_DIR}/Dockerfile" \
  --tag=cyberdojo/commander \
  "${ROOT_DIR}"

readonly IMAGE=cyberdojo/commander
docker tag ${IMAGE}:latest ${IMAGE}:${SHA:0:7}
docker run --rm ${IMAGE}:latest sh -c 'echo ${SHA}'
