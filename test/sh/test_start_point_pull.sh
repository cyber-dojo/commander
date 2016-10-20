#!/bin/bash

. ./cyber_dojo_helpers.sh

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_start_point_pull_prints_use_to_stdout_and_exits_zero()
{
  local expected_stdout="
Use: cyber-dojo start-point pull NAME

Pulls all the docker images inside the named start-point"
  ${exe} start-point pull >${stdoutF} 2>${stderrF}
  local exit_status=$?
  assertTrue ${exit_status}
  assertEqualsStdout "${expected_stdout}"
  assertNoStderr
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_start_point_pull_Help_prints_use_to_stdout_and_exits_zero()
{
  local expected_stdout="
Use: cyber-dojo start-point pull NAME

Pulls all the docker images inside the named start-point"
  ${exe} start-point pull --help >${stdoutF} 2>${stderrF}
  local exit_status=$?
  assertTrue ${exit_status}
  assertEqualsStdout "${expected_stdout}"
  assertNoStderr
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_start_point_pull_AbsentStartPoint_prints_msg_to_stderr_and_exits_non_zero()
{
  local expected_stderr='FAILED: absent does not exist.'
  ${exe} start-point pull absent >${stdoutF} 2>${stderrF}
  local exit_status=$?
  assertFalse ${exit_status}
  assertNoStdout
  assertEqualsStderr "${expected_stderr}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_start_point_pull_PresentButNotStartPoint_prints_msg_to_stderr_and_exits_non_zero()
{
  docker volume create --name notStartPoint > /dev/null
  local expected_stderr='FAILED: notStartPoint is not a cyber-dojo start-point.'
  ${exe} start-point pull notStartPoint >${stdoutF} 2>${stderrF}
  local exit_status=$?
  docker volume rm notStartPoint > /dev/null
  assertFalse ${exit_status}
  assertNoStdout
  assertEqualsStderr "${expected_stderr}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_start_point_pull_ExtraArg_prints_msg_to_stderr_and_exits_non_zero()
{
  ${exe} start-point create ok --git=${github_cyber_dojo}/start-points-custom.git
  local expected_stderr='FAILED: unknown argument [extraArg]'
  ${exe} start-point pull ok extraArg >${stdoutF} 2>${stderrF}
  local exit_status=$?
  ${exe} start-point rm ok
  assertFalse ${exit_status}
  assertNoStdout
  assertEqualsStderr "${expected_stderr}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

. ./shunit2_helpers.sh
. ./shunit2
