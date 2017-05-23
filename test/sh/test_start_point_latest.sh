#!/bin/bash

. ./cyber_dojo_helpers.sh

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_START_POINT_LATEST() { :; }

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test___SUCCESS_exits_zero() { :; }

test_____no_arg_prints_use_to_stdout()
{
  local expected_stdout="
Use: cyber-dojo start-point latest NAME

Re-pulls already pulled docker images inside the named start-point"
  ${exe} start-point latest >${stdoutF} 2>${stderrF}
  assertTrue $?
  assertStdoutEquals "${expected_stdout}"
  assertNoStderr
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____help_arg_prints_use_to_stdout()
{
  local expected_stdout="
Use: cyber-dojo start-point latest NAME

Re-pulls already pulled docker images inside the named start-point"
  ${exe} start-point latest --help >${stdoutF} 2>${stderrF}
  assertTrue $?
  assertStdoutEquals "${expected_stdout}"
  assertNoStderr
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test___FAILURE_prints_msg_to_stderr_and_exits_non_zero() { :; }

test_____absent_start_point()
{
  ${exe} start-point latest absent >${stdoutF} 2>${stderrF}
  assertFalse $?
  assertNoStdout
  assertStderrEquals 'FAILED: absent does not exist.'
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____present_but_not_a_start_point()
{
  docker volume create --name notStartPoint > /dev/null
  ${exe} start-point latest notStartPoint >${stdoutF} 2>${stderrF}
  local exit_status=$?
  docker volume rm notStartPoint > /dev/null
  assertFalse ${exit_status}
  assertNoStdout
  assertStderrEquals 'FAILED: notStartPoint is not a cyber-dojo start-point.'
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____extra_arg()
{
  ${exe} start-point create ok --git=${github_cyber_dojo}/start-points-custom.git
  ${exe} start-point latest ok extraArg >${stdoutF} 2>${stderrF}
  local exit_status=$?
  ${exe} start-point rm ok
  assertFalse ${exit_status}
  assertNoStdout
  assertStderrEquals 'FAILED: unknown argument [extraArg]'
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

. ./shunit2_helpers.sh
. ./shunit2
