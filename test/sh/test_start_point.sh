#!/bin/bash

. ./cyber_dojo_helpers.sh

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_START_POINT() { :; }

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test___SUCCESS_exits_zero() { :; }

test_____help_arg_prints_use_to_stdout()
{
  local expected_stdout="
Use: cyber-dojo start-point [COMMAND]

Manage cyber-dojo start-points

Commands:
  create         Creates a new start-point
  inspect        Displays details of a start-point
  latest         Updates docker images named inside a start-point
  ls             Lists the names of all start-points
  pull           Pulls all the docker images named inside a start-point
  rm             Removes a start-point

Run 'cyber-dojo start-point COMMAND --help' for more information on a command"
  #${exe} start-point >${stdoutF} 2>${stderrF}
  #assertTrue $?
  assertStartPoint
  assertStdoutEquals "${expected_stdout}"
  assertNoStderr
  ${exe} start-point --help >${stdoutF} 2>${stderrF}
  assertTrue $?
  assertStdoutEquals "${expected_stdout}"
  assertNoStderr
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test___FAILURE_prints_msg_to_stderr_and_exits_non_zero() { :; }

test_____unknown_arg()
{
  #${exe} start-point unknown >${stdoutF} 2>${stderrF}
  #assertFalse $?
  local arg=parr
  refuteStartPoint ${arg}
  assertNoStdout
  assertStderrEquals "FAILED: unknown argument [${arg}]"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

. ./shunit2_helpers.sh
. ./shunit2
