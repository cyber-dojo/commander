#!/bin/bash

. ./cyber_dojo_helpers.sh

test_down_help_prints_use_to_stdout_and_exits_zero()
{
  local expected_stdout="
Use: cyber-dojo down

Stops and removes docker containers created with 'up'"
  ${exe} down --help >${stdoutF} 2>${stderrF}
  local exit_status=$?
  assertTrue ${exit_status}
  assertEqualsStdout "${expected_stdout}"
  assertNoStderr
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_down_unknown_prints_msg_to_stderr_and_exits_non_zero()
{
  local expected_stderr="FAILED: unknown argument [unknown]"
  ${exe} down unknown >${stdoutF} 2>${stderrF}
  local exit_status=$?
  assertFalse ${exit_status}
  assertNoStdout
  assertEqualsStderr "${expected_stderr}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

. ./shunit2_helpers.sh
. ./shunit2
