#!/bin/bash

MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"
. ${MY_DIR}/cyber_dojo_helpers.sh

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_SH() { :; }

readonly help_text="
Use: cyber-dojo sh SERVICE

Shells into a service container
Example: cyber-dojo sh web
Example: cyber-dojo sh runner"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test___success() { :; }

test_____no_arg_prints_use()
{
  assertSh
  assertStdoutEquals "${help_text}"
  assertNoStderr
}

test_____help_arg_prints_use()
{
  assertSh --help
  assertStdoutEquals "${help_text}"
  assertNoStderr

  assertSh -h
  assertStdoutEquals "${help_text}"
  assertNoStderr
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test___failure() { :; }

test_____arg_is_not_a_running_container()
{
  local -r arg=wibble
  refuteSh ${arg}
  assertNoStdout
  assertStderrEquals "ERROR: cyber_dojo_${arg} is not a running container"
}

test_____extra_arg_prints_use()
{
  refuteSh wibble fubar
  assertStdoutEquals "${help_text}"
  assertNoStderr
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

. ${MY_DIR}/shunit2_helpers.sh
. ${MY_DIR}/shunit2
