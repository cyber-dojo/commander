#!/bin/bash

. ./cyber_dojo_helpers.sh

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_SH() { :; }

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test___success() { :; }

test_____help_arg_prints_use()
{
  local expected_stdout="
Use: cyber-dojo sh [CONTAINER]

Shells into the named cyber-dojo docker container
Defaults to shelling into cyber-dojo-web container"
  assertSh --help
  assertStdoutEquals "${expected_stdout}"
  assertNoStderr
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test___failure() { :; }

test_____arg_is_not_a_running_container()
{
  local arg=wibble
  refuteSh ${arg}
  assertNoStdout
  assertStderrEquals "FAILED: ${arg} is not a running container"
}

test_____more_than_one_arg_prints_use()
{
  local expected_stdout="
Use: cyber-dojo sh [CONTAINER]

Shells into the named cyber-dojo docker container
Defaults to shelling into cyber-dojo-web container"

  refuteSh wibble fubar
  assertStdoutEquals "${expected_stdout}"
  assertNoStderr
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

. ./shunit2_helpers.sh
. ./shunit2
