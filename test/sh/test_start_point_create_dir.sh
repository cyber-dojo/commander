#!/bin/bash

. ./cyber_dojo_helpers.sh

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_START_POINT_CREATE_DIR() { :; }

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test___success() { :; }

test_____good_dir_with_new_name_creates_start_point_prints_nothing()
{
  local name=good
  local good_dir=`absPath ./../rb/example_start_points/custom`
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
  local name=good
  local bad_dir=/does/not/exist
  refuteStartPointCreate ${name} --dir=${bad_dir}
  assertNoStdout
  assertStderrIncludes "FAILED: dir ${bad_dir} does not exist"
}

test_____good_dir_but_name_already_exists()
{
  local name=good
  local good_dir=`absPath ./../rb/example_start_points/custom`
  assertStartPointCreate ${name} --dir=${good_dir}
  refuteStartPointCreate ${name} --dir=${good_dir}
  assertNoStdout
  assertStderrEquals "FAILED: a start-point called ${name} already exists"
  assertStartPointRm ${name}
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____types_are_not_all_the_same()
{
  local name=jj
  local url=`absPath ./../rb/example_start_points/bad_mixed_types`
  refuteStartPointCreate ${name} --dir=${url}
  assertNoStdout
  assertStderrIncludes "/data/start_point_type.json: type: different types in start_point_type.json files"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____missing_manifest_content()
{
  local name=bad
  local bad_dir=`absPath ./../rb/example_start_points/bad_custom`
  refuteStartPointExists ${name}
  refuteStartPointCreate ${name} --dir=${bad_dir}
  assertNoStdout
  assertStderrIncludes "FAILED..."
  assertStderrIncludes "Tennis/C#/manifest.json: Xdisplay_name: unknown key"
  assertStderrIncludes "Tennis/C#/manifest.json: display_name: missing"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

. ./shunit2_helpers.sh
. ./shunit2
