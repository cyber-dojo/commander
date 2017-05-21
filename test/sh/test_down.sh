#!/bin/bash

. ./cyber_dojo_helpers.sh

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_CYBER_DOJO_DOWN()
{
  :
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_help_arg_prints_use_to_stdout_and_exits_zero()
{
  local expected_stdout="
Use: cyber-dojo down

Stops and removes docker containers created with 'up'"
  ${exe} down --help >${stdoutF} 2>${stderrF}
  assertTrue $?
  assertEqualsStdout "${expected_stdout}"
  assertNoStderr
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_unknown_arg_prints_msg_to_stderr_and_exits_non_zero()
{
  local expected_stderr="FAILED: unknown argument [unknown]"
  ${exe} down unknown >${stdoutF} 2>${stderrF}
  assertFalse $?
  assertNoStdout
  assertEqualsStderr "${expected_stderr}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_no_args_removes_containers_exits_zero()
{
  ${exe} up >${stdoutF} 2>${stderrF}
  assertTrue $?
  ${exe} down >${stdoutF} 2>${stderrF}
  local exit_status=$?
  ${exe} start-point rm languages
  ${exe} start-point rm exercises
  ${exe} start-point rm custom
  assertTrue ${exit_status}
  assertNoStdout
  # docker-compose down writes to stderr in an odd way
  # and it appears to be impossible to capture
  local containers=$(docker ps -a)
  if [[ "${containers}" == *"cyber-dojo-nginx"* ]]; then
    fail "cyber-dojo-nginx container still exists"
  fi
  if [[ "${containers}" == *"cyber-dojo-web"* ]]; then
    fail "cyber-dojo-web container still exists"
  fi
  if [[ "${containers}" == *"cyber-dojo-differ"* ]]; then
    fail "cyber-dojo-differ container still exists"
  fi
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

. ./shunit2_helpers.sh
. ./shunit2
