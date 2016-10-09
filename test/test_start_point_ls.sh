#!/bin/bash

github_cyber_dojo='https://github.com/cyber-dojo'

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_start_point_help_prints_use_to_stdout_and_exits_zero()
{
  local expectedStdout="
Use: cyber-dojo start-point [OPTIONS] ls

Lists the names of all cyber-dojo start-points

  --quiet     Only display start-point names"
  ./../cyber-dojo start-point ls help >${stdoutF} 2>${stderrF}
  local exit_status=$?
  assertTrue ${exit_status}
  assertEqualsStdout "${expectedStdout}"
  assertNoStderr
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_start_point_ls_UnknownArg_prints_terge_msg_to_stderr_exits_non_zero()
{
  local expectedStderr='FAILED: unknown argument [salmo]'
  ./../cyber-dojo start-point ls salmo >${stdoutF} 2>${stderrF}
  local exit_status=$?
  assertFalse ${exit_status}
  assertNoStdout
  assertEqualsStderr "${expectedStderr}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_start_point_ls_prints_nothing_when_no_volumes_and_exits_zero()
{
  ./../cyber-dojo start-point ls >${stdoutF} 2>${stderrF}
  local exit_status=$?
  assertTrue ${exit_status}
  assertNoStdout
  assertNoStderr
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_start_point_ls_quiet_prints_nothing_when_no_volumes_and_exits_zero()
{
  ./../cyber-dojo start-point ls --quiet >${stdoutF} 2>${stderrF}
  local exit_status=$?
  assertTrue ${exit_status}
  assertNoStdout
  assertNoStderr
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_start_point_ls_quiet_prints_just_names_and_exits_zero()
{
  local name=jj
  local url="${github_cyber_dojo}/start-points-exercises.git"
  ./../cyber-dojo start-point create ${name} --git=${url} >${stdoutF} 2>${stderrF}

  local expectedStdout='jj'
  ./../cyber-dojo start-point ls --quiet >${stdoutF} 2>${stderrF}
  local exit_status=$?
  assertTrue ${exit_status}
  assertEqualsStdout "${expectedStdout}"
  assertNoStderr

  ./../cyber-dojo start-point rm ${name}
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_start_point_ls_prints_heading_and_names_and_exits_zero()
{
  local name=jj
  local url="${github_cyber_dojo}/start-points-exercises.git"
  ./../cyber-dojo start-point create ${name} --git=${url} >${stdoutF} 2>${stderrF}

  local expectedStdoutHeading='NAME   TYPE        SRC'
  local expectedStdoutLine='jj     exercises   https://github.com/cyber-dojo/start-points-exercises.git'

  ./../cyber-dojo start-point ls >${stdoutF} 2>${stderrF}

  local exit_status=$?
  assertTrue ${exit_status}
  if [[ "`cat ${stdoutF}`" != *"${expectedStdoutHeading}"* ]]; then
    fail "expected stdout to include ${expectedStdoutHeading}"
  fi
  if [[ "`cat ${stdoutF}`" != *"${expectedStdoutLine}"* ]]; then
    fail "expected stdout to include ${expectedStdoutLine}"
  fi
  assertNoStderr

  ./../cyber-dojo start-point rm ${name}
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

. ./shunit2_helpers.sh
. ./shunit2
