#!/bin/bash
set -e

readonly MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"

cd "${MY_DIR}/sh" && ./build_docker_images.sh
cd "${MY_DIR}/test/sh" && ./run.sh
