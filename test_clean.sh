#!/bin/bash

test_cyberdojo_clean_help_prints_use_to_stdout_and_exits_zero()
{
  expectedStdout="
Use: cyber-dojo clean

Removes dangling docker images"
  ./cyber-dojo clean help >${stdoutF} 2>${stderrF}
  exit_status=$?
  assertTrue ${exit_status}
  assertEqualsStdout "${expectedStdout}"
  assertNoStderr
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_cyberdojo_clean_unknown_prints_terse_msg_to_stderr_and_exits_non_zero()
{
  expectedStderr="FAILED: unknown argument [unknown]"
  ./cyber-dojo clean unknown >${stdoutF} 2>${stderrF}
  exit_status=$?
  assertFalse ${exit_status}
  assertNoStdout
  assertEqualsStderr "${expectedStderr}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_cyberdojo_clean_produces_no_output_exits_zero()
{
  # Can give the following
  # Error response from daemon: conflict: unable to delete cfc459985b4b (cannot be forced)
  #   image is being used by running container a7108a524a4d
  ./cyber-dojo clean >${stdoutF} 2>${stderrF}
  exit_status=$?
  assertTrue ${exit_status}
  assertNoStdout
  assertNoStderr
  # repeat
  ./cyber-dojo clean >${stdoutF} 2>${stderrF}
  exit_status=$?
  assertTrue ${exit_status}
  assertNoStdout
  assertNoStderr
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

. ./test_helpers.sh
. ./shunit2
