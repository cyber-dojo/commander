#!/bin/bash

. ./cyber_dojo_helpers.sh

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_START_POINT_PULL() { :; }

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test___success() { :; }

test_____no_arg_or_help_prints_use()
{
  local expected_stdout="
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
  local arg='absent'
  refuteStartPointPull ${arg}
  assertNoStdout
  assertStderrEquals "FAILED: ${arg} does not exist."
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____present_but_not_a_start_point()
{
  local arg='notStartPoint'
  docker volume create --name ${arg} > /dev/null
  refuteStartPointPull ${arg}
  docker volume rm ${arg} > /dev/null
  assertNoStdout
  assertStderrEquals "FAILED: ${arg} is not a cyber-dojo start-point."
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____extra_arg()
{
  local name='ok'
  local extra='salmon'
  assertStartPointCreate ${name} --git=${github_cyber_dojo}/start-points-custom.git
  refuteStartPointPull ${name} ${extra}
  assertNoStdout
  assertStderrEquals "FAILED: unknown argument [${extra}]"
  assertStartPointRm ${name}
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

. ./shunit2_helpers.sh
. ./shunit2
