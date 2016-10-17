#!/bin/bash

. ./cyber_dojo_helpers.sh

test_update_help_prints_use_to_stdout_and_exits_zero()
{
  local expectedStdout="
Use: cyber-dojo update

Updates all cyber-dojo docker images and the cyber-dojo script file"
  ${exe} update --help >${stdoutF} 2>${stderrF}
  local exit_status=$?
  assertTrue ${exit_status}
  assertEqualsStdout "${expectedStdout}"
  assertNoStderr
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_update_unknown_prints_terse_msg_to_stderr_and_exits_non_zero()
{
  local expectedStderr="FAILED: unknown argument [unknown]"
  ${exe} update unknown >${stdoutF} 2>${stderrF}
  local exit_status=$?
  assertFalse ${exit_status}
  assertNoStdout
  assertEqualsStderr "${expectedStderr}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_update_images_prints_terse_msg_to_stderr_and_exits_non_zero()
{
  # update-images is only callable indirectly via
  # ./cyber-dojo update
  # after the command line arguments have been checked
  local expectedStderr="FAILED: unknown argument [update-images]"
  ${exe} update-images >${stdoutF} 2>${stderrF}
  local exit_status=$?
  assertFalse ${exit_status}
  echo "??? ECHO TO STDERR ????"
  assertNoStderr
  assertEqualsStdout "${expectedStderr}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

. ./shunit2_helpers.sh
. ./shunit2
