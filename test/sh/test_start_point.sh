#!/bin/bash

. ./cyber_dojo_helpers.sh

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_CYBER_DOJO_START_POINT()
{
  :
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_help_arg_prints_use_to_stdout_and_exits_zero()
{
  local expected_stdout="
Use: cyber-dojo start-point [COMMAND]

Manage cyber-dojo start-points

Commands:
  create         Creates a new start-point
  rm             Removes a start-point
  latest         Updates docker images named inside a start-point
  ls             Lists the names of all start-points
  inspect        Displays details of a start-point
  pull           Pulls all the docker images named inside a start-point

Run 'cyber-dojo start-point COMMAND --help' for more information on a command"
  ${exe} start-point >${stdoutF} 2>${stderrF}
  assertTrue $?
  assertEqualsStdout "${expected_stdout}"
  assertNoStderr
  ${exe} start-point --help >${stdoutF} 2>${stderrF}
  assertTrue $?
  assertEqualsStdout "${expected_stdout}"
  assertNoStderr
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_unknown_arg_prints_msg_to_stderr_and_exits_non_zero()
{
  local expected_stderr="FAILED: unknown argument [unknown]"
  ${exe} start-point unknown >${stdoutF} 2>${stderrF}
  assertFalse $?
  assertNoStdout
  assertEqualsStderr "${expected_stderr}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

. ./shunit2_helpers.sh
. ./shunit2
