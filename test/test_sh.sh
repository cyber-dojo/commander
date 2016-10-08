#!/bin/bash

test_sh_help_prints_use_to_stdout_and_exits_zero()
{
  local expectedStdout="
Use: cyber-dojo sh

Shells into the cyber-dojo web server docker container"
  ./../cyber-dojo sh help >${stdoutF} 2>${stderrF}
  local exit_status=$?
  assertTrue ${exit_status}
  assertEqualsStdout "${expectedStdout}"
  assertNoStderr
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_sh_unknown_prints_terse_msg_to_stderr_and_exits_non_zero()
{
  local expectedStderr="FAILED: unknown argument [unknown]"
  ./../cyber-dojo sh unknown >${stdoutF} 2>${stderrF}
  local exit_status=$?
  assertFalse ${exit_status}
  assertNoStdout
  assertEqualsStderr "${expectedStderr}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

. ./shunit2_helpers.sh
. ./shunit2
