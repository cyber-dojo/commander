#!/bin/bash -e

readonly MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"

for file in ${MY_DIR}/test_*.sh; do
  echo "Running ${file}"
  ${file}
done
