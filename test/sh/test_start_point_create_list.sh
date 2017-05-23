#!/bin/bash

# Some of these tests will fail
#   o) if you do not have a network connection
#   o) if github is down

. ./cyber_dojo_helpers.sh

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_START_POINT_CREATE_LIST() { :; }

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test___SUCCESS_exits_zero() { :; }

test_____new_name_creates_start_point_prints_each_url()
{
  local name=jj
  local url="${github_cyber_dojo}/start-points-exercises.git-UNUSED_AT_PRESENT"
  assertStartPointCreate ${name} --list=${url}
  assertStdoutIncludes 'https://github.com/cyber-dojo-languages/elm-test'
  assertStdoutIncludes 'https://github.com/cyber-dojo-languages/haskell-hunit'
  assertNoStderr
  assertStartPointRm ${name}
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test___FAILURE_prints_msg_to_stderr_and_exits_non_zero() { :; }

test_____name_already_exists()
{
  local name=jj
  local url="${github_cyber_dojo}/start-points-exercises.git"
  assertStartPointCreate ${name} --git=${url}
  refuteStartPointCreate ${name} --list=${url}
  assertNoStdout
  assertStderrEquals "FAILED: a start-point called ${name} already exists"
  assertStartPointRm ${name}
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

. ./shunit2_helpers.sh
. ./shunit2
