#!/bin/bash

. ./cyber_dojo_helpers.sh

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_START_POINT_INSPECT() { :; }

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test___SUCCESS_exits_zero() { :; }

test_____no_args_prints_use_to_stdout()
{
  local expected_stdout="
Use: cyber-dojo start-point inspect NAME

Displays details of the named start-point"
  assertStartPointInspect
  assertStdoutEquals "${expected_stdout}"
  assertNoStderr
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____help_arg_prints_use_to_stdout()
{
  local expected_stdout="
Use: cyber-dojo start-point inspect NAME

Displays details of the named start-point"
  assertStartPointInspect --help
  assertStdoutEquals "${expected_stdout}"
  assertNoStderr
}

test_____custom_start_point_prints_details_to_stdout()
{
  local name=ok
  assertStartPointCreate ${name} --git=${github_cyber_dojo}/start-points-custom.git
  assertStartPointInspect ${name}

  local stdout="`cat ${stdoutF}`"
  local expected_titles=( 'MAJOR_NAME' 'MINOR_NAME' 'IMAGE_NAME' )
  for expected_title in "${expected_titles[@]}"
  do
    if ! grep -q ${expected_title} <<< "${stdout}"; then
      fail "expected stdout to include ${expected_title}"
    fi
  done
  local expected_entries=( 'Tennis\srefactoring' 'C#\sNUnit' 'cyberdojofoundation/csharp_nunit' )
  for expected_entry in "${expected_entries[@]}"
  do
    if ! grep -q ${expected_entry} <<< "${stdout}"; then
      fail "expected stdout to include ${expected_entry}"
    fi
  done

  assertNoStderr
  assertStartPointRm ${name}
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____exercises_start_point_prints_details_to_stdout()
{
  local name=ok
  assertStartPointCreate ${name} --git=${github_cyber_dojo}/start-points-exercises.git
  assertStartPointInspect ${name}

  local stdout="`cat ${stdoutF}`"
  local expected_exercises=( 'Fizz\sBuzz' 'Mars\sRover' 'Print\sDiamond' )
  for expected_exercise in "${expected_exercises[@]}"
  do
    if ! grep -q ${expected_exercise} <<< "${stdout}"; then
      fail "expected stdout to include ${expected_exercise}"
    fi
  done

  assertNoStderr
  assertStartPointRm ${name}
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test___FAILURE_prints_msg_to_stderr_and_exits_non_zero() { :; }

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

test_____extra_arg()
{
  local name=pl
  local extra=wibble
  assertStartPointCreate ${name} --git=${github_cyber_dojo}/start-points-custom.git
  refuteStartPointInspect ${name} ${extra}
  assertNoStdout
  assertStderrEquals "FAILED: unknown argument [${extra}]"
  assertStartPointRm ${name}
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

. ./shunit2_helpers.sh
. ./shunit2
