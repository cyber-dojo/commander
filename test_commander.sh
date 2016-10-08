#!/bin/bash

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

test_cyberdojo_clean()
{
  # Can give the following
  # Error response from daemon: conflict: unable to delete cfc459985b4b (cannot be forced)
  #   image is being used by running container a7108a524a4d
  ./cyber-dojo clean >${stdoutF} 2>${stderrF}
  exit_status=$?
  assertTrue ${exit_status}
  assertNoStdout
  assertNoStderr
  # repeat
  ./cyber-dojo clean >${stdoutF} 2>${stderrF}
  exit_status=$?
  assertTrue ${exit_status}
  assertNoStdout
  assertNoStderr
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

assertEqualsStdout() { assertEquals 'stdout' "$1" "`cat ${stdoutF}`"; }
assertEqualsStderr() { assertEquals 'stderr' "$1" "`cat ${stderrF}`"; }
assertNoStdout() { assertEqualsStdout ""; }
assertNoStderr() { assertEqualsStderr ""; }

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

oneTimeSetUp()
{
  outputDir="${SHUNIT_TMPDIR}/output"
  mkdir "${outputDir}"
  stdoutF="${outputDir}/stdout"
  stderrF="${outputDir}/stderr"
  mkdirCmd='mkdir'  # save command name in variable to make future changes easy
  testDir="${SHUNIT_TMPDIR}/some_test_dir"
}

# load and run shUnit2
. shunit2
