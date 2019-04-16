#!/bin/bash

MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"

. ${MY_DIR}/cyber_dojo_helpers.sh

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_START_POINT() { :; }

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test___success() { :; }

test_____no_arg_and_help_arg_prints_use()
{
  local readonly expected_stdout="
Use: cyber-dojo start-point [COMMAND]

Manage cyber-dojo start-points

Commands:
  create         Creates a new start-point from a list of git-repo urls
  inspect        Displays details of a named start-point
  ls             Lists the names of all start-points
  rm             Removes a named start-point
  update         Updates all the docker images inside a named start-point

For more information on a command run:
  cyber-dojo start-point COMMAND --help"
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
  local readonly arg=parr
  refuteStartPoint ${arg}
  assertNoStdout
  assertStderrEquals "FAILED: unknown argument [${arg}]"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____unknown_args()
{
  local readonly arg1=parr
  local readonly arg2=egg
  refuteStartPoint ${arg1} ${arg2}
  assertNoStdout
  assertStderrIncludes "FAILED: unknown argument [${arg1}]"
  assertStderrIncludes "FAILED: unknown argument [${arg2}]"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

. ${MY_DIR}/shunit2_helpers.sh
. ${MY_DIR}/shunit2
