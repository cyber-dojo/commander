#!/bin/bash

. ./cyber_dojo_helpers.sh

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_CYBER_DOJO_START_POINT_CREATE_DIR()
{
  :
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_from_good_dir_with_new_name_prints_nothing_and_exits_zero()
{
  local name=good
  local good_dir=./../rb/example_start_points/custom
  ${exe} start-point create ${name} --dir=${good_dir} >${stdoutF} 2>${stderrF}
  assertTrue $?
  assertNoStdout
  assertNoStderr
  ${exe} start-point ls --quiet >${stdoutF} 2>${stderrF}
  assertStdoutIncludes ${name}

  ${exe} start-point rm ${name}
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_from_good_dir_but_name_exists_prints_msg_to_stderr_and_exits_non_zero()
{
  local name=good
  local good_dir=./../rb/example_start_points/custom
  ${exe} start-point create ${name} --dir=${good_dir} >${stdoutF} 2>${stderrF}
  assertTrue $?

  local expected_stderr="FAILED: a start-point called ${name} already exists"
  ${exe} start-point create ${name} --dir=${good_dir} >${stdoutF} 2>${stderrF}
  assertFalse $?
  assertNoStdout
  assertEqualsStderr "${expected_stderr}"

  ${exe} start-point rm ${name}
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_from_bad_dir_prints_msg_to_stderr_and_exits_non_zero()
{
  local expected_stderr="FAILED...
/data/Tennis/C#/manifest.json: Xfilename_extension: unknown key"
  # TODO: lose /data/ from output?
  # TODO: secretly pass host path to commander?

  local bad_dir=./../rb/example_start_points/bad_custom
  ${exe} start-point create bad --dir=${bad_dir} >${stdoutF} 2>${stderrF}
  assertFalse $?
  assertNoStdout
  assertEqualsStderr "${expected_stderr}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

. ./shunit2_helpers.sh
. ./shunit2
