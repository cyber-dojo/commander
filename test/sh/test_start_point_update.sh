#!/bin/bash

MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"

. ${MY_DIR}/cyber_dojo_helpers.sh

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_START_POINT_PULL() { :; }

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test___success() { :; }

test_____no_arg_or_help_prints_use()
{
  local readonly expected_stdout="
Use: cyber-dojo start-point pull NAME

Pulls all the docker images inside the named start-point"
  assertStartPointPull
  assertStdoutEquals "${expected_stdout}"
  assertNoStderr

  assertStartPointPull --help
  assertStdoutEquals "${expected_stdout}"
  assertNoStderr
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test___failure() { :; }

test_____absent_start_point()
{
  local readonly arg=absent
  refuteStartPointPull ${arg}
  assertNoStdout
  assertStderrEquals "FAILED: ${arg} does not exist."
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____present_but_not_a_start_point()
{
  local readonly arg=notStartPoint
  docker volume create --name ${arg} > /dev/null
  refuteStartPointPull ${arg}
  docker volume rm ${arg} > /dev/null
  assertNoStdout
  assertStderrEquals "FAILED: ${arg} is not a cyber-dojo start-point."
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____unknown_arg()
{
  local readonly name=ok
  local readonly arg=salmon
  assertStartPointCreate ${name} --git=${github_cyber_dojo}/start-points-custom.git
  refuteStartPointPull ${name} ${arg}
  assertNoStdout
  assertStderrEquals "FAILED: unknown argument [${arg}]"
  assertStartPointRm ${name}
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____unknown_args()
{
  local readonly name=ok
  local readonly arg1=salmon
  local readonly arg2=ova
  assertStartPointCreate ${name} --git=${github_cyber_dojo}/start-points-custom.git
  refuteStartPointPull ${name} ${arg1} ${arg2}
  assertNoStdout
  assertStderrIncludes "FAILED: unknown argument [${arg1}]"
  assertStderrIncludes "FAILED: unknown argument [${arg2}]"
  assertStartPointRm ${name}
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

. ${MY_DIR}/shunit2_helpers.sh
. ${MY_DIR}/shunit2
