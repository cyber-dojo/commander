
assertStdoutEquals() { assertEquals 'stdout' "$1" "`de_warned_cat ${stdoutF}`"; }
assertStderrEquals() { assertEquals 'stderr' "$1" "`de_warned_cat ${stderrF}`"; }

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

assertNoStdout() { assertStdoutEquals ""; }
assertNoStderr() { assertStderrEquals ""; }

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

assertStdoutIncludes()
{
  local stdout="`de_warned_cat ${stdoutF}`"
  if [[ "${stdout}" != *"${1}"* ]]; then
    echo "<stdout>"
    cat ${stdoutF}
    echo "</stdout>"
    fail "expected stdout to include ${1}"
  fi
}

refuteStdoutIncludes()
{
  local stdout=$(de_warned_cat "${stdoutF}")
  if [[ "${stdout}" = *"${1}"* ]]; then
    echo "<stdout>"
    cat ${stdoutF}
    echo "</stdout>"
    fail "expected stdout to NOT include ${1}"
  fi
}

assertStderrIncludes()
{
  local stderr=$(de_warned_cat "${stderrF}")
  if [[ "${stderr}" != *"${1}"* ]]; then
    echo "<stderr>"
    echo "${stderr}"
    echo "</stderr>"
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

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

absPath()
{
  #use like this [ local resolved=`abspath ./../a/b/c` ]
  cd "$(dirname "$1")"
  printf "%s/%s\n" "$(pwd)" "$(basename "$1")"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

de_warned_cat()
{
  local -r filename="${1}"
  local -r warning="WARNING: The requested image's platform (linux/amd64) does not match the detected host platform (linux/arm64/v8) and no specific platform was requested"
  cat "${filename}" | grep -v "${warning}"
}