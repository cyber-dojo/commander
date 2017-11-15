#!/bin/bash

MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"

. ${MY_DIR}/cyber_dojo_helpers.sh

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_START_POINT_INSPECT() { :; }

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test___success() { :; }

test_____no_args_or_help_prints_use()
{
  local expected_stdout="
Use: cyber-dojo start-point inspect NAME

Displays details of the named start-point"
  assertStartPointInspect
  assertStdoutEquals "${expected_stdout}"
  assertNoStderr

  assertStartPointInspect --help
  assertStdoutEquals "${expected_stdout}"
  assertNoStderr
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____custom_start_point_prints_details()
{
  local name=ok
  assertStartPointCreate ${name} --git=${github_cyber_dojo}/start-points-custom.git
  assertStartPointInspect ${name}
  assertStdoutIncludes 'MAJOR_NAME'
  assertStdoutIncludes 'MINOR_NAME'
  assertStdoutIncludes 'IMAGE_NAME'
  assertStdoutIncludes 'Tennis refactoring'
  assertStdoutIncludes 'C# NUnit'
  assertNoStderr
  assertStartPointRm ${name}
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____exercises_start_point_prints_details()
{
  local name=ok
  assertStartPointCreate ${name} --git=${github_cyber_dojo}/start-points-exercises.git
  assertStartPointInspect ${name}
  assertStdoutIncludes 'Fizz Buzz'
  assertStdoutIncludes 'Mars Rover'
  assertStdoutIncludes 'Print Diamond'
  assertNoStderr
  assertStartPointRm ${name}
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test___failure() { :; }

test_____absent_start_point()
{
  local name=absent
  refuteStartPointInspect ${name}
  assertNoStdout
  assertStderrEquals "FAILED: ${name} does not exist."
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____present_but_not_a_start_point()
{
  local name=notStartPoint
  docker volume create --name ${name} > /dev/null
  refuteStartPointInspect ${name}
  docker volume rm ${name} > /dev/null
  assertNoStdout
  assertStderrEquals "FAILED: ${name} is not a cyber-dojo start-point."
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____unknown_arg()
{
  local name=ok
  local arg=wibble
  assertStartPointCreate ${name} --git=${github_cyber_dojo}/start-points-custom.git
  refuteStartPointInspect ${name} ${arg}
  assertNoStdout
  assertStderrEquals "FAILED: unknown argument [${arg}]"
  assertStartPointRm ${name}
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____unknown_args()
{
  local name=ok
  local arg1=springer
  local arg2=salmon
  assertStartPointCreate ${name} --git=${github_cyber_dojo}/start-points-custom.git
  refuteStartPointInspect ${name} ${arg1} ${arg2}
  assertNoStdout
  assertStderrIncludes "FAILED: unknown argument [${arg1}]"
  assertStderrIncludes "FAILED: unknown argument [${arg2}]"
  assertStartPointRm ${name}
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

. ${MY_DIR}/shunit2_helpers.sh
. ${MY_DIR}/shunit2
