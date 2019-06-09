#!/bin/bash

MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"
. ${MY_DIR}/cyber_dojo_helpers.sh

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_ENV_FILE_override() { :; }

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test___success() { :; }

test_____web_env_file_exists_seen_as_custom___docker_machine()
{
  if [ -n "${DOCKER_MACHINE_NAME}" ]; then
    local -r web_env=/home/docker/webA.env
    docker-machine ssh "${DOCKER_MACHINE_NAME}" "touch ${web_env}"
    export CYBER_DOJO_WEB_ENV="${web_env}"
    assertUp
    unset CYBER_DOJO_WEB_ENV
    docker-machine ssh "${DOCKER_MACHINE_NAME}" "rm ${web_env}"
    assertStdoutIncludes 'Using web.env=custom'
    down
  fi
}

test_____web_env_file_exists_seen_as_custom___host()
{
  if [ -z "${DOCKER_MACHINE_NAME}" ]; then
    local -r web_env=/tmp/webB.env
    touch "${web_env}"
    export CYBER_DOJO_WEB_ENV="${web_env}"
    assertUp
    unset CYBER_DOJO_WEB_ENV
    rm "${web_env}"
    assertStdoutIncludes 'Using web.env=custom'
    down
  fi
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test___failure() { :; }

test_____web_env_file_does_not_exist_diagnostic___docker_machine()
{
  if [ -n "${DOCKER_MACHINE_NAME}" ]; then
    local -r web_env=/home/docker/webX.env
    export CYBER_DOJO_WEB_ENV="${web_env}"
    refuteUp
    unset CYBER_DOJO_WEB_ENV
    assertStderrIncludes 'ERROR: bad environment variable'
    assertStderrIncludes "CYBER_DOJO_WEB_ENV=${web_env}"
    assertStderrIncludes "does not exist (on VM '${DOCKER_MACHINE_NAME}')"
  fi
}

test_____web_env_file_does_not_exist_diagnostic___host()
{
  if [ -z "${DOCKER_MACHINE_NAME}" ]; then
    local -r web_env=/tmp/webX.env
    export CYBER_DOJO_WEB_ENV="${web_env}"
    refuteUp
    unset CYBER_DOJO_WEB_ENV
    assertStderrIncludes 'ERROR: bad environment variable'
    assertStderrIncludes "CYBER_DOJO_WEB_ENV=${web_env}"
    assertStderrIncludes 'does not exist (on the host)'
  fi
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

. ${MY_DIR}/shunit2_helpers.sh
. ${MY_DIR}/shunit2
