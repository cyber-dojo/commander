#!/bin/bash

test_cyberdojo_with_no_args_prints_use_to_stdout()
{
  ./cyber-dojo >${stdoutF} 2>${stderrF}
  rtrn=$?
  assertTrue ${rtrn}
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

  assertEquals "${expectedStdout}" "`cat ${stdoutF}`"
  assertEquals "" "`cat ${stderrF}`"
}

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
