
assertStdoutEquals() { assertEquals 'stdout' "$1" "`cat ${stdoutF}`"; }
assertStderrEquals() { assertEquals 'stderr' "$1" "`cat ${stderrF}`"; }

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

assertNoStdout() { assertStdoutEquals ""; }
assertNoStderr() { assertStderrEquals ""; }

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

assertStdoutIncludes()
{
  local stdout="`cat ${stdoutF}`"
  if [[ "${stdout}" != *"${1}"* ]]; then
    fail "expected stdout to include ${1}"
  fi
}

assertStderrIncludes()
{
  local stderr="`cat ${stderrF}`"
  if [[ "${stderr}" != *"${1}"* ]]; then
    fail "expected stderr to include ${1}"
  fi
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
