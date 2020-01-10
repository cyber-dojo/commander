#!/bin/bash
set -e

readonly IMAGE=cyberdojo/versioner:latest
readonly RELEASE=$(docker run --entrypoint "" --rm ${IMAGE} sh -c 'echo -n ${RELEASE}')
readonly SHA=$(docker run --entrypoint "" --rm ${IMAGE} sh -c 'echo -n ${SHA}')
readonly TAG=${SHA:0:7}

if [ -n "${RELEASE}" ]; then
  echo "${RELEASE}"
else
  echo "${TAG}"
  echo 'Warning: this is a development version'
fi
