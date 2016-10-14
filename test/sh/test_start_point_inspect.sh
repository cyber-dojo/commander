#!/bin/bash

. ./cyber_dojo_helpers.sh

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_start_point_inspect_NoArgs_prints_use_to_stdout_and_exits_zero()
{
  local expectedStdout="
Use: cyber-dojo start-point inspect NAME

Displays details of the named start-point"
  ${exe} start-point inspect >${stdoutF} 2>${stderrF}
  local exit_status=$?
  assertTrue ${exit_status}
  assertEqualsStdout "${expectedStdout}"
  assertNoStderr
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_start_point_inspect_Help_prints_use_to_stdout_and_exits_zero()
{
  local expectedStdout="
Use: cyber-dojo start-point inspect NAME

Displays details of the named start-point"
  ${exe} start-point inspect --help >${stdoutF} 2>${stderrF}
  local exit_status=$?
  assertTrue ${exit_status}
  assertEqualsStdout "${expectedStdout}"
  assertNoStderr
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_start_point_inspect_AbsentStartPoint_prints_terse_msg_to_stderr_and_exits_non_zero()
{
  local expectedStderr='FAILED: absent does not exist.'
  ${exe} start-point inspect absent >${stdoutF} 2>${stderrF}
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
  ${exe} start-point inspect notStartPoint >${stdoutF} 2>${stderrF}
  local exit_status=$?
  docker volume rm notStartPoint > /dev/null
  assertFalse ${exit_status}
  assertNoStdout
  assertEqualsStderr "${expectedStderr}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_start_point_inspect_ExtraArg_prints_terse_msg_to_stderr_and_exits_non_zero()
{
  ${exe} start-point create ok --git=${github_cyber_dojo}/start-points-custom.git
  local expectedStderr='FAILED: unknown argument [extraArg]'
  ${exe} start-point inspect ok extraArg >${stdoutF} 2>${stderrF}
  local exit_status=$?
  ${exe} start-point rm ok
  assertFalse ${exit_status}
  assertNoStdout
  assertEqualsStderr "${expectedStderr}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_start_point_inspect_StartPoint_prints_details_and_exits_zero()
{
  ${exe} start-point create ok --git=${github_cyber_dojo}/start-points-custom.git
  ${exe} start-point inspect ok >${stdoutF} 2>${stderrF}
  local exit_status=$?
  ${exe} start-point rm ok
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
