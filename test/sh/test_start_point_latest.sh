#!/bin/bash

. ./cyber_dojo_helpers.sh

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_START_POINT_LATEST() { :; }

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test___SUCCESS_exits_zero() { :; }

test_____no_arg_or_help_prints_use_to_stdout()
{
  local expected_stdout="
Use: cyber-dojo start-point latest NAME

Re-pulls already pulled docker images inside the named start-point"
  assertStartPointLatest
  assertStdoutEquals "${expected_stdout}"
  assertNoStderr

  assertStartPointLatest --help
  assertStdoutEquals "${expected_stdout}"
  assertNoStderr
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test___FAILURE_prints_msg_to_stderr_and_exits_non_zero() { :; }

test_____absent_start_point()
{
  local name=absent
  refuteStartPointLatest ${name}
  assertNoStdout
  assertStderrEquals "FAILED: ${name} does not exist."
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____present_but_not_a_start_point()
{
  local name=notStartPoint
  docker volume create --name ${name} > /dev/null
  refuteStartPointLatest ${name}
  assertNoStdout
  assertStderrEquals "FAILED: ${name} is not a cyber-dojo start-point."
  docker volume rm notStartPoint > /dev/null
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____extra_arg()
{
  local name=ok
  assertStartPointCreate ${name} --git=${github_cyber_dojo}/start-points-custom.git
  local extra=salmon
  refuteStartPointLatest ${name} ${extra}
  assertNoStdout
  assertStderrEquals "FAILED: unknown argument [${extra}]"
  assertStartPointRm ${name}
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

. ./shunit2_helpers.sh
. ./shunit2
