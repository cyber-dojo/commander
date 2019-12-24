#!/bin/bash

MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"
. ${MY_DIR}/cyber_dojo_helpers.sh

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_ENV_FILE_override() { :; }

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test___success() { :; }

test_____env_files_exist_seen_as_custom___docker_machine()
{
  if [ -n "${DOCKER_MACHINE_NAME}" ]; then
    local -r nginx_env=/home/docker/nginx.env.exists
    local -r web_env=/home/docker/web.env.exists
    docker-machine ssh "${DOCKER_MACHINE_NAME}" "touch ${nginx_env} ${web_env}"
    export CYBER_DOJO_NGINX_ENV="${nginx_env}"
    export CYBER_DOJO_WEB_ENV="${web_env}"
    assertUp
    unset CYBER_DOJO_WEB_ENV
    unset CYBER_DOJO_NGINX_ENV
    docker-machine ssh "${DOCKER_MACHINE_NAME}" "rm ${nginx_env} ${web_env}"
    assertStdoutIncludes "Using nginx.env=${nginx_env} (non-default)"
    assertStdoutIncludes "Using web.env=${web_env} (non-default)"
    down
  fi
}

test_____web_env_file_exists_seen_as_custom___host()
{
  if [ -z "${DOCKER_MACHINE_NAME}" ]; then
    local -r nginx_env=/tmp/nginx.env.exists
    local -r web_env=/tmp/web.env.exists
    touch "${nginx_env}" "${web_env}"
    export CYBER_DOJO_NGINX_ENV="${nginx_env}"
    export CYBER_DOJO_WEB_ENV="${web_env}"
    assertUp
    unset CYBER_DOJO_WEB_ENV
    unset CYBER_DOJO_NGINX_ENV
    rm "${nginx_env}" "${web_env}"
    assertStdoutIncludes "Using nginx.env=${nginx_env} (non-default)"
    assertStdoutIncludes "Using web.env=${web_env} (non-default)"
    down
  fi
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test___failure() { :; }

test_____nginx_env_file_does_not_exist_diagnostic___docker_machine()
{
  if [ -n "${DOCKER_MACHINE_NAME}" ]; then
    local -r nginx_env=/home/docker/nginx.env.does.not.exist
    export CYBER_DOJO_NGINX_ENV="${nginx_env}"
    refuteUp
    unset CYBER_DOJO_NGINX_ENV
    assertStderrIncludes 'ERROR: bad environment variable'
    assertStderrIncludes "CYBER_DOJO_NGINX_ENV=${nginx_env}"
    assertStderrIncludes "does not exist (on VM '${DOCKER_MACHINE_NAME}')"
  fi
}

test_____web_env_file_does_not_exist_diagnostic___docker_machine()
{
  if [ -n "${DOCKER_MACHINE_NAME}" ]; then
    local -r web_env=/home/docker/web.env.does.not.exist
    export CYBER_DOJO_WEB_ENV="${web_env}"
    refuteUp
    unset CYBER_DOJO_WEB_ENV
    assertStderrIncludes 'ERROR: bad environment variable'
    assertStderrIncludes "CYBER_DOJO_WEB_ENV=${web_env}"
    assertStderrIncludes "does not exist (on VM '${DOCKER_MACHINE_NAME}')"
  fi
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____nginx_env_file_does_not_exist_diagnostic___host()
{
  if [ -z "${DOCKER_MACHINE_NAME}" ]; then
    local -r nginx_env=/tmp/nginx.env.does.not.exist
    export CYBER_DOJO_NGINX_ENV="${nginx_env}"
    refuteUp
    unset CYBER_DOJO_NGINX_ENV
    assertStderrIncludes 'ERROR: bad environment variable'
    assertStderrIncludes "CYBER_DOJO_NGINX_ENV=${nginx_env}"
    assertStderrIncludes 'does not exist (on the host)'
  fi
}

test_____web_env_file_does_not_exist_diagnostic___host()
{
  if [ -z "${DOCKER_MACHINE_NAME}" ]; then
    local -r web_env=/tmp/web.env.does.not.exist
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
