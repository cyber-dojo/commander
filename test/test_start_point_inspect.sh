#!/bin/bash

github_cyber_dojo='https://github.com/cyber-dojo'

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_start_point_inspect_NoArgs_prints_use_to_stdout_and_exits_zero()
{
  local expectedStdout="
Use: cyber-dojo start-point inspect NAME

Displays details of the named start-point"
  ./../cyber-dojo start-point inspect >${stdoutF} 2>${stderrF}
  local exit_status=$?
  assertTrue ${exit_status}
  assertEqualsStdout "${expectedStdout}"
  assertNoStderr
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_start_point_inspect_help_prints_use_to_stdout_and_exits_zero()
{
  local expectedStdout="
Use: cyber-dojo start-point inspect NAME

Displays details of the named start-point"
  ./../cyber-dojo start-point inspect help >${stdoutF} 2>${stderrF}
  local exit_status=$?
  assertTrue ${exit_status}
  assertEqualsStdout "${expectedStdout}"
  assertNoStderr
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_start_point_inspect_AbsentStartPoint_prints_terse_msg_to_stderr_and_exits_non_zero()
{
  local expectedStderr='FAILED: absent does not exist.'
  ./../cyber-dojo start-point inspect absent >${stdoutF} 2>${stderrF}
  local exit_status=$?
  assertFalse ${exit_status}
  assertNoStdout
  assertEqualsStderr "${expectedStderr}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_start_point_inspect_PresentButNotStartPoint_prints_terse_msg_to_stderr_and_exits_non_zero()
{
  docker volume create --name notStartPoint > /dev/null
  local expectedStderr='FAILED: notStartPoint is not a cyber-dojo start-point.'
  ./../cyber-dojo start-point inspect notStartPoint >${stdoutF} 2>${stderrF}
  local exit_status=$?
  docker volume rm notStartPoint > /dev/null
  assertFalse ${exit_status}
  assertNoStdout
  assertEqualsStderr "${expectedStderr}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_start_point_inspect_ExtraArg_prints_terse_msg_to_stderr_and_exits_non_zero()
{
  ./../cyber-dojo start-point create ok --git=${github_cyber_dojo}/start-points-custom.git
  local expectedStderr='FAILED: unknown argument [extraArg]'
  ./../cyber-dojo start-point inspect ok extraArg >${stdoutF} 2>${stderrF}
  local exit_status=$?
  ./../cyber-dojo start-point rm ok
  assertFalse ${exit_status}
  assertNoStdout
  assertEqualsStderr "${expectedStderr}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_start_point_inspect_StartPoint_prints_details_and_exits_zero()
{
  ./../cyber-dojo start-point create ok --git=${github_cyber_dojo}/start-points-custom.git
  ./../cyber-dojo start-point inspect ok >${stdoutF} 2>${stderrF}
  local exit_status=$?
  ./../cyber-dojo start-point rm ok
  assertTrue ${exit_status}

  local stdout="`cat ${stdoutF}`"
  local expectedTitles=( 'MAJOR_NAME' 'MINOR_NAME' 'IMAGE_NAME' )
  for expectedTitle in "${expectedTitles[@]}"
  do
    if ! grep -q ${expectedTitle} <<< "${stdout}"; then
      fail "expected stdout to include ${expectedTitle}"
    fi
  done
  local expectedEntries=( 'Tennis\srefactoring' 'C#\sNUnit' 'cyberdojofoundation/csharp_nunit' )
  for expectedEntry in "${expectedEntries[@]}"
  do
    if ! grep -q ${expectedEntry} <<< "${stdout}"; then
      fail "expected stdout to include ${expectedEntry}"
    fi
  done

  assertNoStderr
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

. ./shunit2_helpers.sh
. ./shunit2
