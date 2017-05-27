#!/bin/bash

. ./cyber_dojo_helpers.sh

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_SUCCESS_exits_zero_no_stderr_prints_to_stdout() { :; }
test_FAILURE_exits_non_zero_no_stdout_prints_to_stderr() { :; }

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_CLEAN() { :; }

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test___success() { :; }

test_____help_arg_prints_use()
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

test___failure() { :; }

test_____extra_arg()
{
  local name=extra
  refuteClean ${name}
  assertNoStdout
  assertStderrEquals "FAILED: unknown argument [${name}]"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____extra_args()
{
  local extra1=salmon
  local extra2=parr
  refuteClean ${extra1} ${extra2}
  assertNoStdout
  assertStderrIncludes "FAILED: unknown argument [${extra1}]"
  assertStderrIncludes "FAILED: unknown argument [${extra2}]"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

. ./shunit2_helpers.sh
. ./shunit2
