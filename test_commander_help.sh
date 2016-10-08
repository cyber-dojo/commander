#!/bin/bash

# TODO: add [help,--help] processing for ALL commands, eg clean,down,up

test_cyberdojo_with_no_args_or_minus_minus_help_prints_use_to_stdout()
{
  expectedStdout="
Use: cyber-dojo [--debug] COMMAND
     cyber-dojo --help

Commands:
    clean        Removes dangling images
    down         Brings down the server
    logs         Prints the logs from the server
    sh           Shells into the server
    up           Brings up the server
    update       Updates the server to the latest image
    start-point  Manages cyber-dojo start-points

Run 'cyber-dojo COMMAND --help' for more information on a command."
  ./cyber-dojo >${stdoutF} 2>${stderrF}
  exit_status=$?
  assertTrue ${exit_status}
  assertEqualsStdout "${expectedStdout}"
  assertEqualsStderr ""
  # and with --help
  ./cyber-dojo --help >${stdoutF} 2>${stderrF}
  exit_status=$?
  assertTrue ${exit_status}
  assertEqualsStdout "${expectedStdout}"
  assertEqualsStderr ""
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_cyberdojo_clean_minus_minus_help_prints_use_to_stdout()
{
  expectedStdout="
Use: cyber-dojo clean

Removes dangling docker images"
  ./cyber-dojo clean --help >${stdoutF} 2>${stderrF}
  exit_status=$?
  assertTrue ${exit_status}
  assertEqualsStdout "${expectedStdout}"
  assertEqualsStderr ""
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_cyberdojo_down_minus_minus_help_prints_use_to_stdout()
{
  expectedStdout="
Use: cyber-dojo down

Stops and removes docker containers created with 'up'"
  ./cyber-dojo down --help >${stdoutF} 2>${stderrF}
  exit_status=$?
  assertTrue 'true' ${exit_status}
  assertEqualsStdout "${expectedStdout}"
  assertNoStderr
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

. ./test_helpers.sh

# load and run shUnit2
. shunit2
