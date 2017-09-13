#!/bin/bash

. ./cyber_dojo_helpers.sh

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_START_POINT() { :; }

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test___success() { :; }

test_____no_arg_and_help_arg_prints_use()
{
  local expected_stdout="
Use: cyber-dojo start-point [COMMAND]

Manage cyber-dojo start-points

Commands:
  create         Creates a new start-point
  inspect        Displays details of a start-point
  latest         Updates pulled docker images named inside a start-point
  ls             Lists the names of all start-points
  pull           Pulls all the docker images named inside a start-point
  rm             Removes a start-point

Run 'cyber-dojo start-point COMMAND --help' for more information on a command"
  assertStartPoint
  assertStdoutEquals "${expected_stdout}"
  assertNoStderr

  assertStartPoint --help
  assertStdoutEquals "${expected_stdout}"
  assertNoStderr
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test___failure() { :; }

test_____unknown_arg()
{
  local arg=parr
  refuteStartPoint ${arg}
  assertNoStdout
  assertStderrEquals "FAILED: unknown argument [${arg}]"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____unknown_args()
{
  local arg1=parr
  local arg2=egg
  refuteStartPoint ${arg1} ${arg2}
  assertNoStdout
  assertStderrIncludes "FAILED: unknown argument [${arg1}]"
  assertStderrIncludes "FAILED: unknown argument [${arg2}]"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

. ./shunit2_helpers.sh
. ./shunit2
