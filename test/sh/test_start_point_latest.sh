#!/bin/bash

. ./cyber_dojo_helpers.sh

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_START_POINT_LATEST() { :; }

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_SUCCESS_exits_zero() { :; }

test_no_arg_prints_use_to_stdout()
{
  local expected_stdout="
Use: cyber-dojo start-point latest NAME

Re-pulls already pulled docker images inside the named start-point"
  ${exe} start-point latest >${stdoutF} 2>${stderrF}
  assertTrue $?
  assertEqualsStdout "${expected_stdout}"
  assertNoStderr
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_help_arg_prints_use_to_stdout()
{
  local expected_stdout="
Use: cyber-dojo start-point latest NAME

Re-pulls already pulled docker images inside the named start-point"
  ${exe} start-point latest --help >${stdoutF} 2>${stderrF}
  assertTrue $?
  assertEqualsStdout "${expected_stdout}"
  assertNoStderr
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_FAILURE_prints_msg_to_stderr_and_exits_non_zero() { :; }

test_absent_start_point()
{
  local expected_stderr='FAILED: absent does not exist.'
  ${exe} start-point latest absent >${stdoutF} 2>${stderrF}
  assertFalse $?
  assertNoStdout
  assertEqualsStderr "${expected_stderr}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_present_but_not_a_start_point()
{
  docker volume create --name notStartPoint > /dev/null
  local expected_stderr='FAILED: notStartPoint is not a cyber-dojo start-point.'
  ${exe} start-point latest notStartPoint >${stdoutF} 2>${stderrF}
  local exit_status=$?
  docker volume rm notStartPoint > /dev/null
  assertFalse ${exit_status}
  assertNoStdout
  assertEqualsStderr "${expected_stderr}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_extra_arg()
{
  ${exe} start-point create ok --git=${github_cyber_dojo}/start-points-custom.git
  local expected_stderr='FAILED: unknown argument [extraArg]'
  ${exe} start-point latest ok extraArg >${stdoutF} 2>${stderrF}
  local exit_status=$?
  ${exe} start-point rm ok
  assertFalse ${exit_status}
  assertNoStdout
  assertEqualsStderr "${expected_stderr}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

. ./shunit2_helpers.sh
. ./shunit2
