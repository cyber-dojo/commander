#!/bin/bash

MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"

. ${MY_DIR}/cyber_dojo_helpers.sh

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_START_POINT_UPDATE() { :; }

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test___success() { :; }

test_____no_arg_or_help_prints_use()
{
  local readonly expected_stdout="
Use: cyber-dojo start-point update NAME

Updates all the docker images inside the named start-point"
  assertStartPointUpdate
  assertStdoutEquals "${expected_stdout}"
  assertNoStderr

  assertStartPointUpdate --help
  assertStdoutEquals "${expected_stdout}"
  assertNoStderr

  assertStartPointUpdate -h
  assertStdoutEquals "${expected_stdout}"
  assertNoStderr
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test___failure() { :; }

test_____absent_start_point()
{
  local readonly arg=absent
  refuteStartPointUpdate ${arg}
  assertNoStdout
  assertStderrEquals "ERROR: ${arg} does not exist."
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

XXX_test_____present_but_not_a_start_point()
{
  local readonly arg=notStartPoint
  docker volume create --name ${arg} > /dev/null
  refuteStartPointUpdate ${arg}
  docker volume rm ${arg} > /dev/null
  assertNoStdout
  assertStderrEquals "ERROR: ${arg} is not a cyber-dojo start-point."
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____unknown_arg()
{
  local readonly name=ok
  local readonly arg=salmon
  assertStartPointCreate ${name} --exercises $(exercises_urls)
  refuteStartPointUpdate ${name} ${arg}
  assertNoStdout
  assertStderrEquals "ERROR: unknown argument [${arg}]"
  assertStartPointRm ${name}
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____unknown_args()
{
  local readonly name=ok
  local readonly arg1=salmon
  local readonly arg2=ova
  assertStartPointCreate ${name} --exercises $(exercises_urls)
  refuteStartPointUpdate ${name} ${arg1} ${arg2}
  assertNoStdout
  assertStderrIncludes "ERROR: unknown argument [${arg1}]"
  assertStderrIncludes "ERROR: unknown argument [${arg2}]"
  assertStartPointRm ${name}
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

. ${MY_DIR}/shunit2_helpers.sh
. ${MY_DIR}/shunit2
