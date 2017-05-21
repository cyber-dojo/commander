#!/bin/bash

. ./cyber_dojo_helpers.sh

test_logs_help_prints_use_to_stdout_and_exits_zero()
{
  local expected_stdout="
Use: cyber-dojo logs

Fetches and prints the logs of the web server (if running)"
  ${exe} logs --help >${stdoutF} 2>${stderrF}
  assertTrue $?
  assertEqualsStdout "${expected_stdout}"
  assertNoStderr
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_logs_unknown_arg_prints_msg_to_stderr_and_exits_non_zero()
{
  local expected_stderr="FAILED: unknown argument [unknown]"
  ${exe} logs unknown >${stdoutF} 2>${stderrF}
  assertFalse $?
  assertNoStdout
  assertEqualsStderr "${expected_stderr}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

. ./shunit2_helpers.sh
. ./shunit2
