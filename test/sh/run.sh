#!/bin/bash
set -e

MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"

# pull here so stdout messages do not intefere with
# tests asserting on contents of stdout
docker pull cyberdojo/versioner:latest

for file in ${MY_DIR}/test_*.sh; do
  ${file}
done
