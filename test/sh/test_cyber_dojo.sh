#!/bin/bash

MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"

. ${MY_DIR}/cyber_dojo_helpers.sh

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_CYBER_DOJO() { :; }

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test___success() { :; }

test_____no_args_or_help_arg_prints_use()
{
  local readonly expected_stdout="
Use: cyber-dojo [--debug] COMMAND
     cyber-dojo --help

Commands:
    clean        Removes old images/volumes/containers
    down         Brings down the server
    logs         Prints the logs from a service container
    sh           Shells into a service container
    start-point  Manages cyber-dojo start-points
    up           Brings up the server
    update       Updates the server and languages to the latest images

Run 'cyber-dojo COMMAND --help' for more information on a command."
  ${exe} >${stdoutF} 2>${stderrF}
  assertTrue $?
  assertStdoutEquals "${expected_stdout}"
  assertNoStderr
  # and with help
  ${exe} --help >${stdoutF} 2>${stderrF}
  assertTrue $?
  assertStdoutEquals "${expected_stdout}"
  assertNoStderr
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test___failure() { :; }

test_____unknown_arg()
{
  local readonly arg=xyz
  ${exe} ${arg} >${stdoutF} 2>${stderrF}
  assertFalse $?
  assertNoStdout
  assertStderrEquals "ERROR: unknown argument [${arg}]"
}

#TODO unknown args (plural)

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

. ${MY_DIR}/shunit2_helpers.sh
. ${MY_DIR}/shunit2
