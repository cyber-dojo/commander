#!/bin/bash

test_cyberdojo_start_point_help_prints_use_to_stdout_and_exits_zero()
{
  expectedStdout="
Use: cyber-dojo start-point [COMMAND]

Manage cyber-dojo start-points

Commands:
  create         Creates a new start-point
  rm             Removes a start-point
  ls             Lists the names of all start-points
  inspect        Displays details of a start-point
  pull           Pulls all the docker images named inside a start-point

Run 'cyber-dojo start-point COMMAND help' for more information on a command"
  ./cyber-dojo start-point >${stdoutF} 2>${stderrF}
  exit_status=$?
  assertTrue ${exit_status}
  assertEqualsStdout "${expectedStdout}"
  assertNoStderr
  ./cyber-dojo start-point help >${stdoutF} 2>${stderrF}
  exit_status=$?
  assertTrue ${exit_status}
  assertEqualsStdout "${expectedStdout}"
  assertNoStderr
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_cyberdojo_start_point_unknown_prints_terse_msg_to_stderr_and_exits_non_zero()
{
  expectedStderr="FAILED: unknown argument [unknown]"
  ./cyber-dojo start-point unknown >${stdoutF} 2>${stderrF}
  exit_status=$?
  assertFalse ${exit_status}
  assertNoStdout
  assertEqualsStderr "${expectedStderr}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_cyberdojo_start_point_create_help_prints_use_to_stdout_and_exits_zero()
{
  expectedStdout="
Use: cyber-dojo start-point create NAME --git=URL
Creates a start-point named NAME from a git clone of URL

Use: cyber-dojo start-point create NAME --dir=DIR
Creates a start-point named NAME from a copy of DIR

NAME's first letter must be [a-zA-Z0-9]
NAME's remaining letters must be [a-zA-Z0-9_.-]
NAME must be at least two letters long"
  ./cyber-dojo start-point create >${stdoutF} 2>${stderrF}
  exit_status=$?
  assertTrue ${exit_status}
  assertEqualsStdout "${expectedStdout}"
  assertNoStderr
  ./cyber-dojo start-point create help >${stdoutF} 2>${stderrF}
  exit_status=$?
  assertTrue ${exit_status}
  assertEqualsStdout "${expectedStdout}"
  assertNoStderr
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

. ./test_helpers.sh
. ./shunit2
