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
  assertClean --help
  assertStdoutEquals "${expected_stdout}"
  assertNoStderr
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____no_args_produces_no_output_leaves_no_dangling_images_or_exited_containers()
{
  assertClean
  assertNoStdout
  assertNoStderr
  local dangling_images=`docker images --quiet --filter='dangling=true'`
  assertEquals "" "${dangling_images}"
  local exited_containers=`docker ps --all --quiet --filter='status=exited'`
  assertEquals "" "${exited_containers}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test___FAILURE_prints_msg_to_stderr_exits_non_zero() { :; }

test_____extra_arg()
{
  local name=extra
  refuteClean ${name}
  assertNoStdout
  assertStderrEquals "FAILED: unknown argument [${name}]"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

. ./shunit2_helpers.sh
. ./shunit2
