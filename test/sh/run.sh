#!/bin/bash -Ee

readonly MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"

# An optional argument narrows the run to the test files whose name contains it,
# eg 065 runs only test_065_update.sh. No argument runs them all.
readonly TIDS="${1:-}"

for file in ${MY_DIR}/test_*${TIDS}*.sh; do
  echo "Running ${file}"
  ${file}
done
