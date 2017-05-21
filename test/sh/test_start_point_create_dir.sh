#!/bin/bash

. ./cyber_dojo_helpers.sh

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_START_POINT_CREATE_DIR() { :; }

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_SUCCESS_exits_zero() { :; }

test_from_good_dir_with_new_name_creates_start_point_prints_nothing()
{
  local name=good
  local good_dir=./../rb/example_start_points/custom

  refuteStartPointExists ${name}
  startPointCreateDir ${name} ${good_dir}
  assertTrue $?
  assertNoStdout
  assertNoStderr
  assertStartPointExists ${name}

  startPointRm ${name}
  refuteStartPointExists ${name}
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_FAILURE_prints_msg_to_stderr_and_exits_non_zero() { :; }

test_from_good_dir_but_name_exists()
{
  local name=good
  local good_dir=./../rb/example_start_points/custom

  refuteStartPointExists ${name}
  startPointCreateDir ${name} ${good_dir}
  assertStartPointExists ${name}

  local expected_stderr="FAILED: a start-point called ${name} already exists"

  startPointCreateDir ${name} ${good_dir}
  assertFalse $?
  assertNoStdout
  assertEqualsStderr "${expected_stderr}"
  assertStartPointExists ${name}

  startPointRm ${name}
  refuteStartPointExists ${name}
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_from_bad_dir_content()
{
  local expected_stderr="FAILED...
/data/Tennis/C#/manifest.json: Xfilename_extension: unknown key"
  # TODO: lose /data/ from output?
  # TODO: secretly pass host path to commander?

  local name=bad
  local bad_dir=./../rb/example_start_points/bad_custom

  refuteStartPointExists ${name}
  startPointCreateDir ${name} ${bad_dir}
  assertFalse $?
  assertNoStdout
  assertEqualsStderr "${expected_stderr}"
  refuteStartPointExists ${name}
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

. ./shunit2_helpers.sh
. ./shunit2
