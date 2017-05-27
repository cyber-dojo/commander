#!/bin/bash

. ./cyber_dojo_helpers.sh

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_LOGS() { :; }

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test___sucess() { :; }

test_____help_arg_prints_use()
{
  local expected_stdout="
Use: cyber-dojo logs

Fetches and prints the logs of the web server (if running)"
  assertLogs --help
  assertStdoutEquals "${expected_stdout}"
  assertNoStderr
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test___failure() { :; }

test_____unknown_arg()
{
  local extra=salmon
  refuteLogs ${extra}
  assertNoStdout
  assertStderrEquals "FAILED: unknown argument [${extra}]"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

. ./shunit2_helpers.sh
. ./shunit2
