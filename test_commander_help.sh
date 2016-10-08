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

test_cyberdojo_logs_minus_minus_help_prints_use_to_stdout()
{
  expectedStdout="
Use: cyber-dojo logs

Fetches and prints the logs of the web server (if running)"
  ./cyber-dojo logs --help >${stdoutF} 2>${stderrF}
  exit_status=$?
  assertTrue 'true' ${exit_status}
  assertEqualsStdout "${expectedStdout}"
  assertNoStderr
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_cyberdojo_sh_minus_minus_help_prints_use_to_stdout()
{
  expectedStdout="
Use: cyber-dojo sh

Shells into the cyber-dojo web server docker container"
  ./cyber-dojo sh --help >${stdoutF} 2>${stderrF}
  exit_status=$?
  assertTrue 'true' ${exit_status}
  assertEqualsStdout "${expectedStdout}"
  assertNoStderr
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_cyberdojo_up_minus_minus_help_prints_use_to_stdout()
{
  expectedStdout="
Use: cyber-dojo up [OPTIONS]

Creates and starts the cyber-dojo server using named/default start-points

  --languages=START-POINT  Specify the languages start-point.
                           Defaults to a start-point named 'languages' created from
                           https://github.com/cyber-dojo/start-points-languages.git
  --exercises=START-POINT  Specify the exercises start-point.
                           Defaults to a start-point named 'exercises' created from
                           https://github.com/cyber-dojo/start-points-exercises.git
  --custom=START-POINT     Specify the custom start-point.
                           Defaults to a start-point named 'custom' created from
                           https://github.com/cyber-dojo/start-points-custom.git"
  ./cyber-dojo up --help >${stdoutF} 2>${stderrF}
  exit_status=$?
  assertTrue 'true' ${exit_status}
  assertEqualsStdout "${expectedStdout}"
  assertNoStderr
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

. ./test_helpers.sh

# load and run shUnit2
. shunit2
