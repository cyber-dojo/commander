#!/bin/bash

MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"
. ${MY_DIR}/cyber_dojo_helpers.sh

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_LOGS() { :; }

readonly help_text="
Use: cyber-dojo logs SERVICE

Prints the logs from a service container
Example: cyber-dojo logs web
Example: cyber-dojo logs saver"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test___sucess() { :; }

test_____no_arg_prints_use()
{
  assertLogs
  assertStdoutEquals "${help_text}"
  assertNoStderr
}

test_____help_arg_prints_use()
{
  assertLogs --help
  assertStdoutEquals "${help_text}"
  assertNoStderr

  assertLogs -h
  assertStdoutEquals "${help_text}"
  assertNoStderr
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test___failure() { :; }

test_____unknown_arg()
{
  local -r arg=salmon
  refuteLogs ${arg}
  assertNoStdout
  assertStderrEquals "ERROR: cyber-dojo-${arg} is not a running container"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____more_than_one_arg_prints_use()
{
  refuteLogs wibble fubar
  assertStdoutEquals "${help_text}"
  assertNoStderr
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

. ${MY_DIR}/shunit2_helpers.sh
. ${MY_DIR}/shunit2
