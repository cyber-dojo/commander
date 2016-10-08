#!/bin/bash

# TODO --debug

test_cyberdojo_with_no_args_or_help_prints_use_to_stdout_and_exits_zero()
{
  expectedStdout="
Use: cyber-dojo [--debug] COMMAND
     cyber-dojo help

Commands:
    clean        Removes dangling images
    down         Brings down the server
    logs         Prints the logs from the server
    sh           Shells into the server
    up           Brings up the server
    update       Updates the server to the latest image
    start-point  Manages cyber-dojo start-points

Run 'cyber-dojo COMMAND help' for more information on a command."
  ./cyber-dojo >${stdoutF} 2>${stderrF}
  exit_status=$?
  assertTrue ${exit_status}
  assertEqualsStdout "${expectedStdout}"
  assertEqualsStderr ""
  # and with help
  ./cyber-dojo help >${stdoutF} 2>${stderrF}
  exit_status=$?
  assertTrue ${exit_status}
  assertEqualsStdout "${expectedStdout}"
  assertEqualsStderr ""
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_cyberdojo_unknown_prints_terse_msg_to_stderr_and_exits_non_zero()
{
  expectedStderr="FAILED: unknown argument [unknown]"
  ./cyber-dojo unknown >${stdoutF} 2>${stderrF}
  exit_status=$?
  assertFalse ${exit_status}
  assertNoStdout
  assertEqualsStderr "${expectedStderr}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

. ./test_helpers.sh
. ./shunit2
