#!/bin/bash

MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"
. ${MY_DIR}/cyber_dojo_helpers.sh

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_ENV_FILE_override() { :; }

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test___success() { :; }

test_____web_env_file_exists_seen_as_custom___host()
{
  local -r nginx_env=/tmp/nginx.env.exists
  local -r web_env=/tmp/web.env.exists
  touch "${nginx_env}" "${web_env}"
  export CYBER_DOJO_NGINX_ENV="${nginx_env}"
  export CYBER_DOJO_WEB_ENV="${web_env}"
  assertUp
  unset CYBER_DOJO_WEB_ENV
  unset CYBER_DOJO_NGINX_ENV
  rm "${nginx_env}" "${web_env}"
  assertStdoutIncludes "Using nginx.env=${nginx_env} (custom)"
  assertStdoutIncludes "Using web.env=${web_env} (custom)"
  down
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test___failure() { :; }

test_____nginx_env_file_does_not_exist_diagnostic___host()
{
  local -r nginx_env=/tmp/nginx.env.does.not.exist
  export CYBER_DOJO_NGINX_ENV="${nginx_env}"
  refuteUp
  unset CYBER_DOJO_NGINX_ENV
  assertStderrIncludes 'ERROR: bad environment variable'
  assertStderrIncludes "CYBER_DOJO_NGINX_ENV=${nginx_env}"
  assertStderrIncludes 'does not exist (on the host)'
}

test_____web_env_file_does_not_exist_diagnostic___host()
{
  local -r web_env=/tmp/web.env.does.not.exist
  export CYBER_DOJO_WEB_ENV="${web_env}"
  refuteUp
  unset CYBER_DOJO_WEB_ENV
  assertStderrIncludes 'ERROR: bad environment variable'
  assertStderrIncludes "CYBER_DOJO_WEB_ENV=${web_env}"
  assertStderrIncludes 'does not exist (on the host)'
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

. ${MY_DIR}/shunit2_helpers.sh
. ${MY_DIR}/shunit2
