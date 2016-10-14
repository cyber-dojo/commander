#!/bin/bash

. ./cyber_dojo_helpers.sh

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_start_point_pull_prints_use_to_stdout_and_exits_zero()
{
  local expectedStdout="
Use: cyber-dojo start-point pull NAME

Pulls all the docker images inside the named start-point"
  ${exe} start-point pull >${stdoutF} 2>${stderrF}
  local exit_status=$?
  assertTrue ${exit_status}
  assertEqualsStdout "${expectedStdout}"
  assertNoStderr
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_start_point_pull_Help_prints_use_to_stdout_and_exits_zero()
{
  local expectedStdout="
Use: cyber-dojo start-point pull NAME

Pulls all the docker images inside the named start-point"
  ${exe} start-point pull --help >${stdoutF} 2>${stderrF}
  local exit_status=$?
  assertTrue ${exit_status}
  assertEqualsStdout "${expectedStdout}"
  assertNoStderr
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_start_point_pull_AbsentStartPoint_prints_terse_msg_to_stderr_and_exits_non_zero()
{
  local expectedStderr='FAILED: absent does not exist.'
  ${exe} start-point pull absent >${stdoutF} 2>${stderrF}
  local exit_status=$?
  assertFalse ${exit_status}
  assertNoStdout
  assertEqualsStderr "${expectedStderr}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_start_point_pull_PresentButNotStartPoint_prints_terse_msg_to_stderr_and_exits_non_zero()
{
  docker volume create --name notStartPoint > /dev/null
  local expectedStderr='FAILED: notStartPoint is not a cyber-dojo start-point.'
  ${exe} start-point pull notStartPoint >${stdoutF} 2>${stderrF}
  local exit_status=$?
  docker volume rm notStartPoint > /dev/null
  assertFalse ${exit_status}
  assertNoStdout
  assertEqualsStderr "${expectedStderr}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_start_point_pull_ExtraArg_prints_terse_msg_to_stderr_and_exits_non_zero()
{
  ${exe} start-point create ok --git=${github_cyber_dojo}/start-points-custom.git
  local expectedStderr='FAILED: unknown argument [extraArg]'
  ${exe} start-point pull ok extraArg >${stdoutF} 2>${stderrF}
  local exit_status=$?
  ${exe} start-point rm ok
  assertFalse ${exit_status}
  assertNoStdout
  assertEqualsStderr "${expectedStderr}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

. ./shunit2_helpers.sh
. ./shunit2
