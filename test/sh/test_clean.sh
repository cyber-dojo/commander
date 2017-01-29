#!/bin/bash

. ./cyber_dojo_helpers.sh

test_clean_help_prints_use_to_stdout_and_exits_zero()
{
  local expected_stdout="
Use: cyber-dojo clean

Removes dangling docker images/volumes and exited containers"
  ${exe} clean --help >${stdoutF} 2>${stderrF}
  assertTrue $?
  assertEqualsStdout "${expected_stdout}"
  assertNoStderr
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_clean_unknown_prints_msg_to_stderr_and_exits_non_zero()
{
  local expected_stderr="FAILED: unknown argument [unknown]"
  ${exe} clean unknown >${stdoutF} 2>${stderrF}
  assertFalse $?
  assertNoStdout
  assertEqualsStderr "${expected_stderr}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_clean_produces_no_output_leaves_no_danglingImages_or_exitedContainers_and_exits_zero()
{
  ${exe} clean >${stdoutF} 2>${stderrF}
  assertTrue $?
  assertNoStdout
  assertNoStderr
  local dangling_images=`docker images --quiet --filter='dangling=true'`
  assertEquals "" "${dangling_images}"
  local exited_containers=`docker ps --all --quiet --filter='status=exited'`
  assertEquals "" "${exited_containers}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

#. ./shunit2_helpers.sh
#. ./shunit2
