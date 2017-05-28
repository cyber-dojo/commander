#!/bin/bash

# Some of these tests will fail
#   o) if you do not have a network connection
#   o) if github is down

. ./cyber_dojo_helpers.sh

test_START_POINT_CREATE_GIT() { :; }

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test___success() { :; }

test_____good_git_repo_with_new_name_creates_start_point_prints_url()
{
  local name=jj
  local url="${github_cyber_dojo}/start-points-exercises.git"
  assertStartPointCreate ${name} --git=${url}
  assertStdoutIncludes ${url}
  assertNoStderr
  assertStartPointExists ${name}
  assertStartPointRm ${name}
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test___failure() { :; }

test_____name_already_exists()
{
  local name=jj
  local url="${github_cyber_dojo}/start-points-exercises.git"
  assertStartPointCreate ${name} --git=${url}
  refuteStartPointCreate ${name} --git=${url}
  assertNoStdout
  assertStderrEquals "FAILED: a start-point called ${name} already exists"
  assertStartPointRm ${name}
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____bad_git_content()
{
  local name=bad
  local repo='elm-test-bad-manifest-for-testing'
  local url="https://github.com/cyber-dojo-languages/${repo}"
  refuteStartPointExists ${name}
  refuteStartPointCreate ${name} --git=${url}
  assertStdoutIncludes ${url}
  assertStderrIncludes "FAILED..."
  assertStderrIncludes "${repo}/manifest.json: Ximage_name: unknown key"
  assertStderrIncludes "${repo}/manifest.json: image_name: missing"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

. ./shunit2_helpers.sh
. ./shunit2
