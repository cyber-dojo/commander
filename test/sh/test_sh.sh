#!/bin/bash

. ./cyber_dojo_helpers.sh

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_SH() { :; }

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_SUCCESS_exits_zero() { :; }

test_help_arg_prints_use_to_stdout()
{
  local expected_stdout="
Use: cyber-dojo sh

Shells into the cyber-dojo web server docker container"
  ${exe} sh --help >${stdoutF} 2>${stderrF}
  assertTrue $?
  assertEqualsStdout "${expected_stdout}"
  assertNoStderr
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_FAILURE_prints_msg_to_stderr_and_exits_non_zero() { :; }

test_unknown_arg()
{
  local expected_stderr="FAILED: unknown argument [unknown]"
  ${exe} sh unknown >${stdoutF} 2>${stderrF}
  assertFalse $?
  assertNoStdout
  assertEqualsStderr "${expected_stderr}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

. ./shunit2_helpers.sh
. ./shunit2
