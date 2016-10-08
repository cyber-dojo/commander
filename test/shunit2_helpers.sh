
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
