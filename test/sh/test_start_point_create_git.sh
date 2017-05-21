#!/bin/bash

# Some of these tests will fail
#   o) if you do not have a network connection
#   o) if github is down

. ./cyber_dojo_helpers.sh

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_CYBER_DOJO_START_POINT_CREATE_GIT()
{
  :
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

startPointCreateGit()
{
  local name=$1
  local url=$2
  ${exe} start-point create ${name} --git=${url} >${stdoutF} 2>${stderrF}
}

test_from_good_git_repo_with_new_name_creates_start_point_prints_nothing_and_exits_zero()
{
  local name=jj
  local url="${github_cyber_dojo}/start-points-exercises.git"
  refuteStartPointExists ${name}
  startPointCreateGit ${name} ${url}
  assertTrue $?
  assertNoStdout
  assertNoStderr
  assertStartPointExists ${name}
  startPointRm ${name}
  refuteStartPointExists ${name}
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_from_good_git_repo_but_name_exists_prints_msg_to_stderr_and_exits_non_zero()
{
  local name=jj
  local url="${github_cyber_dojo}/start-points-exercises.git"
  refuteStartPointExists ${name}
  startPointCreateGit ${name} ${url}
  assertTrue $?
  assertStartPointExists ${name}

  local expected_stderr="FAILED: a start-point called ${name} already exists"
  startPointCreateGit ${name} ${url}
  assertFalse $?
  assertNoStdout
  assertEqualsStderr "${expected_stderr}"
  assertStartPointExists ${name}
  startPointRm ${name}
  refuteStartPointExists ${name}
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

. ./shunit2_helpers.sh
. ./shunit2
