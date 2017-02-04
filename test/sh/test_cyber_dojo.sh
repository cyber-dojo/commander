#!/bin/bash

. ./cyber_dojo_helpers.sh

test_with_no_args_or_help_prints_use_to_stdout_and_exits_zero()
{
  #clean        Removes old images/volumes/containers
  local expected_stdout="
Use: cyber-dojo [--debug] COMMAND
     cyber-dojo --help

Commands:
    clean        Removes old images/volumes/containers
    down         Brings down the server
    logs         Prints the logs from the server
    sh           Shells into the server
    up           Brings up the server
    update       Updates the server to the latest images
    start-point  Manages cyber-dojo start-points

Run 'cyber-dojo COMMAND --help' for more information on a command."
  ${exe} >${stdoutF} 2>${stderrF}
  assertTrue $?
  assertEqualsStdout "${expected_stdout}"
  assertEqualsStderr ""
  # and with help
  ${exe} --help >${stdoutF} 2>${stderrF}
  assertTrue $?
  assertEqualsStdout "${expected_stdout}"
  assertEqualsStderr ""
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_unknown_prints_msg_to_stderr_and_exits_non_zero()
{
  local expected_stderr="FAILED: unknown argument [unknown]"
  ${exe} unknown >${stdoutF} 2>${stderrF}
  assertFalse $?
  assertNoStdout
  assertEqualsStderr "${expected_stderr}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

. ./shunit2_helpers.sh
. ./shunit2
