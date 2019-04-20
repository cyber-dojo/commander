#!/bin/bash

MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"

. ${MY_DIR}/cyber_dojo_helpers.sh

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_START_POINT_INSPECT() { :; }

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test___success() { :; }

test_____no_args_or_help_prints_use()
{
  local readonly expected_stdout="
Use: cyber-dojo start-point inspect NAME

Prints, in JSON form, the display_name, image_name, sha, and url of each entry in the named start-point"
  assertStartPointInspect
  assertStdoutEquals "${expected_stdout}"
  assertNoStderr

  assertStartPointInspect --help
  assertStdoutEquals "${expected_stdout}"
  assertNoStderr
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

xtest_____custom_start_point_prints_details()
{
  local readonly name=ok
  assertStartPointCreate ${name} --git=${github_cyber_dojo}/start-points-custom.git
  assertStartPointInspect ${name}
  assertStdoutIncludes 'DISPLAY_NAME'
  assertStdoutIncludes 'IMAGE_NAME'
  assertStdoutIncludes 'Tennis refactoring, C# NUnit'
  assertNoStderr
  assertStartPointRm ${name}
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

xtest_____exercises_start_point_prints_details()
{
  local readonly name=ok
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
  local readonly name=absent
  refuteStartPointInspect ${name}
  assertNoStdout
  assertStderrEquals "ERROR: ${name} does not exist."
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

xtest_____present_but_not_a_start_point()
{
  local readonly name=notStartPoint
  docker volume create --name ${name} > /dev/null
  refuteStartPointInspect ${name}
  docker volume rm ${name} > /dev/null
  assertNoStdout
  assertStderrEquals "ERROR: ${name} is not a cyber-dojo start-point."
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

xtest_____unknown_arg()
{
  local readonly name=ok
  local readonly arg=wibble
  assertStartPointCreate ${name} --git=${github_cyber_dojo}/start-points-custom.git
  refuteStartPointInspect ${name} ${arg}
  assertNoStdout
  assertStderrEquals "ERROR: unknown argument [${arg}]"
  assertStartPointRm ${name}
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

xtest_____unknown_args()
{
  local readonly name=ok
  local readonly arg1=springer
  local readonly arg2=salmon
  assertStartPointCreate ${name} --git=${github_cyber_dojo}/start-points-custom.git
  refuteStartPointInspect ${name} ${arg1} ${arg2}
  assertNoStdout
  assertStderrIncludes "ERROR: unknown argument [${arg1}]"
  assertStderrIncludes "ERROR: unknown argument [${arg2}]"
  assertStartPointRm ${name}
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

. ${MY_DIR}/shunit2_helpers.sh
. ${MY_DIR}/shunit2
