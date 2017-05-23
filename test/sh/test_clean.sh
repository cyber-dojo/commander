#!/bin/bash

. ./cyber_dojo_helpers.sh

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_CLEAN() { :; }

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test___SUCCESS_exits_zero() { :; }

test_____help_arg_prints_use_to_stdout()
{
  local expected_stdout="
Use: cyber-dojo clean

Removes dangling docker images/volumes and exited containers"
  ${exe} clean --help >${stdoutF} 2>${stderrF}
  assertTrue $?
  assertStdoutEquals "${expected_stdout}"
  assertNoStderr
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____no_args_produces_no_output_leaves_no_dangling_images_or_exited_containers()
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

test___FAILURE_prints_msg_to_stderr_exits_non_zero() { :; }

test_____unknown_arg()
{
  local expected_stderr="FAILED: unknown argument [unknown]"
  ${exe} clean unknown >${stdoutF} 2>${stderrF}
  assertFalse $?
  assertNoStdout
  assertStderrEquals "${expected_stderr}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

. ./shunit2_helpers.sh
. ./shunit2
