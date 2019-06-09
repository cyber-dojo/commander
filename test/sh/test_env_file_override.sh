#!/bin/bash

MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"
. ${MY_DIR}/cyber_dojo_helpers.sh

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_ENV_FILE_override() { :; }

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test___success() { :; }

X_test_____env_file_exists_on_host()
{
  unset DOCKER_MACHINE_NAME
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test___failure() { :; }

test_____env_file_does_not_exist_on_host()
{
  unset DOCKER_MACHINE_NAME
  local -r web_env=/tmp/web.env
  touch "${web_env}"
  export CYBER_DOJO_WEB_ENV="${web_env}_XX"
  refuteUp
  rm "${web_env}"
  assertStderrIncludes 'ERROR: bad environment variable'
  assertStderrIncludes "CYBER_DOJO_WEB_ENV=${web_env}_XX"
  assertStderrIncludes 'does not exist (on the host)'
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

. ${MY_DIR}/shunit2_helpers.sh
. ${MY_DIR}/shunit2
