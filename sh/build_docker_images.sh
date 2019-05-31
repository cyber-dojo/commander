#!/bin/bash
set -e

readonly CONTEXT_DIR="$( cd "$( dirname "${0}" )" && cd .. && pwd )"
readonly SHA=$(cd "${ROOT_DIR}" && git rev-parse HEAD)

docker build \
  --build-arg SHA="${SHA}" \
  --file="${CONTEXT_DIR}/Dockerfile" \
  --tag=cyberdojo/commander \
  "${CONTEXT_DIR}"
