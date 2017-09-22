#!/bin/bash

. ./cyber_dojo_helpers.sh

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_LOGS() { :; }

readonly help_text="
Use: cyber-dojo logs SERVICE

Prints the logs from a service container
Example: cyber-dojo logs web
Example: cyber-dojo logs storer
Example: cyber-dojo logs runner"

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
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test___failure() { :; }

test_____unknown_arg()
{
  local arg=salmon
  refuteLogs ${arg}
  assertNoStdout
  assertStderrEquals "FAILED: cyber-dojo-${arg} is not a running container"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____more_than_one_arg_prints_use()
{
  refuteLogs wibble fubar
  assertStdoutEquals "${help_text}"
  assertNoStderr
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

. ./shunit2_helpers.sh
. ./shunit2
