#!/bin/bash

test_cyberdojo_clean()
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


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

. ./test_helpers.sh

# load and run shUnit2
. shunit2
