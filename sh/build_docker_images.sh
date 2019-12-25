#!/bin/bash
set -e

readonly ROOT_DIR="$( cd "$( dirname "${0}" )" && cd .. && pwd )"

git_commit_sha()
{
  echo $(cd "${ROOT_DIR}" && git rev-parse HEAD)
}

readonly COMMIT_SHA="$(git_commit_sha)"
readonly IMAGE=cyberdojo/commander

docker build \
  --build-arg COMMIT_SHA="${COMMIT_SHA}" \
  --file="${ROOT_DIR}/app/Dockerfile" \
  --tag=${IMAGE} \
  "${ROOT_DIR}/app"

docker tag ${IMAGE}:latest ${IMAGE}:${COMMIT_SHA:0:7}
docker run --rm ${IMAGE}:latest sh -c 'echo ${SHA}'
