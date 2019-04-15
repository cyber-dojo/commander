#!/bin/bash

MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"

. ${MY_DIR}/cyber_dojo_helpers.sh

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_START_POINT_CREATE_DIR() { :; }

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test___success() { :; }

test_____good_dir_with_new_name_creates_start_point_prints_nothing()
{
  local readonly name=good
  local readonly good_dir=`absPath ${MY_DIR}/../rb/example_start_points/custom`
  assertStartPointCreate ${name} --dir=${good_dir}
  assertNoStdout
  assertNoStderr
  assertStartPointExists ${name}
  assertStartPointRm ${name}
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test___failure() { :; }

test_____dir_does_not_exist()
{
  local readonly name=good
  local readonly bad_dir=/does/not/exist
  refuteStartPointCreate ${name} --dir=${bad_dir}
  assertNoStdout
  assertStderrIncludes "FAILED: dir ${bad_dir} does not exist"
}

test_____good_dir_but_name_already_exists()
{
  local readonly name=good
  local readonly good_dir=`absPath ${MY_DIR}/../rb/example_start_points/custom`
  assertStartPointCreate ${name} --dir=${good_dir}
  refuteStartPointCreate ${name} --dir=${good_dir}
  assertNoStdout
  assertStderrEquals "FAILED: a start-point called ${name} already exists"
  assertStartPointRm ${name}
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____types_are_not_all_the_same()
{
  local readonly name=jj
  local readonly url=`absPath ${MY_DIR}/../rb/example_start_points/bad_mixed_types`
  refuteStartPointCreate ${name} --dir=${url}
  assertNoStdout
  assertStderrIncludes "/data/start_point_type.json: type: different types in start_point_type.json files"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____missing_manifest_content()
{
  local readonly name=bad
  local readonly bad_dir=`absPath ${MY_DIR}/../rb/example_start_points/bad_custom`
  refuteStartPointExists ${name}
  refuteStartPointCreate ${name} --dir=${bad_dir}
  assertNoStdout
  assertStderrIncludes "FAILED..."
  assertStderrIncludes "Tennis/C#/manifest.json: Xdisplay_name: unknown key"
  assertStderrIncludes "Tennis/C#/manifest.json: display_name: missing"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

. ${MY_DIR}/shunit2_helpers.sh
. ${MY_DIR}/shunit2
