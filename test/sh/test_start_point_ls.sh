#!/bin/bash

. ./cyber_dojo_helpers.sh

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_START_POINT_LS() { :; }

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test___SUCCESS_exits_zero() { :; }

test_____help_arg_prints_use_to_stdout()
{
  local expected_stdout="
Use: cyber-dojo start-point [OPTIONS] ls

Lists the name, type, and source of all cyber-dojo start-points

  --quiet     Only display start-point names"
  ${exe} start-point ls --help >${stdoutF} 2>${stderrF}
  assertTrue $?
  assertEqualsStdout "${expected_stdout}"
  assertNoStderr
}

test_____no_args_prints_nothing_when_no_volumes()
{
  ${exe} start-point ls >${stdoutF} 2>${stderrF}
  assertTrue $?
  assertNoStdout
  assertNoStderr
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____quiet_arg_prints_nothing_when_no_volumes()
{
  ${exe} start-point ls --quiet >${stdoutF} 2>${stderrF}
  assertTrue $?
  assertNoStdout
  assertNoStderr
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____quiet_arg_prints_just_names_when_volumes_exist()
{
  local name=jj
  local url="${github_cyber_dojo}/start-points-exercises.git"
  ${exe} start-point create ${name} --git=${url} >${stdoutF} 2>${stderrF}

  local expected_stdout='jj'
  ${exe} start-point ls --quiet >${stdoutF} 2>${stderrF}
  assertTrue $?
  assertEqualsStdout "${expected_stdout}"
  assertNoStderr

  ${exe} start-point rm ${name}
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____no_arg_prints_heading_and_names_types_sources()
{
  local name=jj
  local url="${github_cyber_dojo}/start-points-exercises.git"
  ${exe} start-point create ${name} --git=${url} >${stdoutF} 2>${stderrF}
  assertTrue $?

  local expected_stdout_heading='NAME   TYPE        SRC'
  local expected_stdout_line='jj     exercises   https://github.com/cyber-dojo/start-points-exercises.git'

  ${exe} start-point ls >${stdoutF} 2>${stderrF}
  assertTrue $?
  assertStdoutIncludes ${expected_stdout_heading}
  assertStdoutIncludes ${expected_stdout_line}
  assertNoStderr

  ${exe} start-point rm ${name}
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test___FAILURE_prints_msg_to_stderr_and_exits_non_zero() { :; }

test_____unknown_arg()
{
  local expected_stderr='FAILED: unknown argument [salmo]'
  ${exe} start-point ls salmo >${stdoutF} 2>${stderrF}
  assertFalse $?
  assertNoStdout
  assertEqualsStderr "${expected_stderr}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

. ./shunit2_helpers.sh
. ./shunit2
