#!/bin/bash

. ./cyber_dojo_helpers.sh

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_start_point_ls_help_prints_use_to_stdout_and_exits_zero()
{
  local expected_stdout="
Use: cyber-dojo start-point [OPTIONS] ls

Lists the names of all cyber-dojo start-points

  --quiet     Only display start-point names"
  ${exe} start-point ls --help >${stdoutF} 2>${stderrF}
  local exit_status=$?
  assertTrue ${exit_status}
  assertEqualsStdout "${expected_stdout}"
  assertNoStderr
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_start_point_ls_UnknownArg_prints_msg_to_stderr_exits_non_zero()
{
  local expected_stderr='FAILED: unknown argument [salmo]'
  ${exe} start-point ls salmo >${stdoutF} 2>${stderrF}
  local exit_status=$?
  assertFalse ${exit_status}
  assertNoStdout
  assertEqualsStderr "${expected_stderr}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_start_point_ls_prints_nothing_when_no_volumes_and_exits_zero()
{
  ${exe} start-point ls >${stdoutF} 2>${stderrF}
  local exit_status=$?
  assertTrue ${exit_status}
  assertNoStdout
  assertNoStderr
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_start_point_ls_quiet_prints_nothing_when_no_volumes_and_exits_zero()
{
  ${exe} start-point ls --quiet >${stdoutF} 2>${stderrF}
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
  ${exe} start-point create ${name} --git=${url} >${stdoutF} 2>${stderrF}

  local expected_stdout='jj'
  ${exe} start-point ls --quiet >${stdoutF} 2>${stderrF}
  local exit_status=$?
  assertTrue ${exit_status}
  assertEqualsStdout "${expected_stdout}"
  assertNoStderr

  ${exe} start-point rm ${name}
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_start_point_ls_prints_heading_and_names_and_exits_zero()
{
  local name=jj
  local url="${github_cyber_dojo}/start-points-exercises.git"
  ${exe} start-point create ${name} --git=${url} >${stdoutF} 2>${stderrF}
  local exit_status=$?
  assertTrue ${exit_status}

  local expected_stdout_heading='NAME   TYPE        SRC'
  local expected_stdout_line='jj     exercises   https://github.com/cyber-dojo/start-points-exercises.git'

  ${exe} start-point ls >${stdoutF} 2>${stderrF}

  local exit_status=$?
  assertTrue ${exit_status}
  assertStdoutIncludes ${expected_stdout_heading}
  assertStdoutIncludes ${expected_stdout_line}
  assertNoStderr

  ${exe} start-point rm ${name}
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

. ./shunit2_helpers.sh
. ./shunit2
