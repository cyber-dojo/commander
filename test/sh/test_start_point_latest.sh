#!/bin/bash

. ./cyber_dojo_helpers.sh

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_START_POINT_LATEST() { :; }

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test___success() { :; }

test_____no_arg_or_help_prints_use()
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

test___failure() { :; }

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

test_____unknown_arg()
{
  local name=ok
  assertStartPointCreate ${name} --git=${github_cyber_dojo}/start-points-custom.git
  local arg=salmon
  refuteStartPointLatest ${name} ${arg}
  assertNoStdout
  assertStderrEquals "FAILED: unknown argument [${arg}]"
  assertStartPointRm ${name}
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____unknown_args()
{
  local name=ok
  assertStartPointCreate ${name} --git=${github_cyber_dojo}/start-points-custom.git
  local arg1=salmon
  local arg2=parr
  refuteStartPointLatest ${name} ${arg1} ${arg2}
  assertNoStdout
  assertStderrIncludes "FAILED: unknown argument [${arg1}]"
  assertStderrIncludes "FAILED: unknown argument [${arg2}]"
  assertStartPointRm ${name}
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

. ./shunit2_helpers.sh
. ./shunit2
