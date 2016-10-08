#!/bin/bash

test_cyberdojo_sh_help_prints_use_to_stdout_and_exits_zero()
{
  expectedStdout="
Use: cyber-dojo sh

Shells into the cyber-dojo web server docker container"
  ./cyber-dojo sh help >${stdoutF} 2>${stderrF}
  exit_status=$?
  assertTrue ${exit_status}
  assertEqualsStdout "${expectedStdout}"
  assertNoStderr
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_cyberdojo_sh_unknown_prints_terse_msg_to_stderr_and_exits_non_zero()
{
  expectedStderr="FAILED: unknown argument [unknown]"
  ./cyber-dojo sh unknown >${stdoutF} 2>${stderrF}
  exit_status=$?
  assertFalse ${exit_status}
  assertNoStdout
  assertEqualsStderr "${expectedStderr}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

. ./test_helpers.sh
. ./shunit2
