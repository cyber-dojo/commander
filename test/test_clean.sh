#!/bin/bash

test_clean_help_prints_use_to_stdout_and_exits_zero()
{
  local expectedStdout="
Use: cyber-dojo clean

Removes dangling docker images and exited containers"
  ./../cyber-dojo clean --help >${stdoutF} 2>${stderrF}
  local exit_status=$?
  assertTrue ${exit_status}
  assertEqualsStdout "${expectedStdout}"
  assertNoStderr
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_clean_unknown_prints_terse_msg_to_stderr_and_exits_non_zero()
{
  local expectedStderr="FAILED: unknown argument [unknown]"
  ./../cyber-dojo clean unknown >${stdoutF} 2>${stderrF}
  local exit_status=$?
  assertFalse ${exit_status}
  assertNoStdout
  assertEqualsStderr "${expectedStderr}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_clean_produces_no_output_leaves_no_danglingImages_or_exitedContainers_and_exits_zero()
{
  # Can give the following
  # Error response from daemon: conflict: unable to delete cfc459985b4b (cannot be forced)
  #   image is being used by running container a7108a524a4d
  ./../cyber-dojo clean >${stdoutF} 2>${stderrF}
  local exit_status=$?
  assertTrue ${exit_status}
  assertNoStdout
  assertNoStderr
  local danglingImages=`docker images --quiet --filter='dangling=true'`
  assertEquals "" "${danglingImages}"
  local exitedContainers=`docker ps --all --quiet --filter='status=exited'`
  assertEquals "" "${exitedContainers}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

. ./shunit2_helpers.sh
. ./shunit2
