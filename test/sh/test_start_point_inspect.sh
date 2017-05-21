#!/bin/bash

. ./cyber_dojo_helpers.sh

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_CYBER_DOJO_START_POINT_INSPECT()
{
  :
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_no_args_prints_use_to_stdout_and_exits_zero()
{
  local expected_stdout="
Use: cyber-dojo start-point inspect NAME

Displays details of the named start-point"
  ${exe} start-point inspect >${stdoutF} 2>${stderrF}
  assertTrue $?
  assertEqualsStdout "${expected_stdout}"
  assertNoStderr
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_help_arg_prints_use_to_stdout_and_exits_zero()
{
  local expected_stdout="
Use: cyber-dojo start-point inspect NAME

Displays details of the named start-point"
  ${exe} start-point inspect --help >${stdoutF} 2>${stderrF}
  assertTrue $?
  assertEqualsStdout "${expected_stdout}"
  assertNoStderr
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_absent_start_point_prints_msg_to_stderr_and_exits_non_zero()
{
  local expected_stderr='FAILED: absent does not exist.'
  ${exe} start-point inspect absent >${stdoutF} 2>${stderrF}
  assertFalse $?
  assertNoStdout
  assertEqualsStderr "${expected_stderr}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_present_but_not_start_point_prints_msg_to_stderr_and_exits_non_zero()
{
  docker volume create --name notStartPoint > /dev/null
  local expected_stderr='FAILED: notStartPoint is not a cyber-dojo start-point.'
  ${exe} start-point inspect notStartPoint >${stdoutF} 2>${stderrF}
  local exit_status=$?
  docker volume rm notStartPoint > /dev/null
  assertFalse ${exit_status}
  assertNoStdout
  assertEqualsStderr "${expected_stderr}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_extra_arg_prints_msg_to_stderr_and_exits_non_zero()
{
  ${exe} start-point create ok --git=${github_cyber_dojo}/start-points-custom.git
  local expected_stderr='FAILED: unknown argument [extraArg]'
  ${exe} start-point inspect ok extraArg >${stdoutF} 2>${stderrF}
  local exit_status=$?
  ${exe} start-point rm ok
  assertFalse ${exit_status}
  assertNoStdout
  assertEqualsStderr "${expected_stderr}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_custom_start_point_prints_details_and_exits_zero()
{
  ${exe} start-point create ok --git=${github_cyber_dojo}/start-points-custom.git
  ${exe} start-point inspect ok >${stdoutF} 2>${stderrF}
  local exit_status=$?
  ${exe} start-point rm ok
  assertTrue ${exit_status}

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
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_exercises_start_point_prints_details_and_exits_zero()
{
  ${exe} start-point create ok --git=${github_cyber_dojo}/start-points-exercises.git
  ${exe} start-point inspect ok >${stdoutF} 2>${stderrF}
  local exit_status=$?
  ${exe} start-point rm ok
  assertTrue ${exit_status}

  local stdout="`cat ${stdoutF}`"
  local expected_exercises=( 'Fizz\sBuzz' 'Mars\sRover' 'Print\sDiamond' )
  for expected_exercise in "${expected_exercises[@]}"
  do
    if ! grep -q ${expected_exercise} <<< "${stdout}"; then
      fail "expected stdout to include ${expected_exercise}"
    fi
  done

  assertNoStderr
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

. ./shunit2_helpers.sh
. ./shunit2
