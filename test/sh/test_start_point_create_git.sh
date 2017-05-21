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

test_from_good_git_repo_with_new_name_prints_nothing_and_exits_zero()
{
  local name=jj
  local url="${github_cyber_dojo}/start-points-exercises.git"
  ${exe} start-point create ${name} --git=${url} >${stdoutF} 2>${stderrF}
  assertTrue $?
  assertNoStdout
  assertNoStderr
  ${exe} start-point ls --quiet >${stdoutF} 2>${stderrF}
  assertStdoutIncludes ${name}
  ${exe} start-point rm ${name}
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_from_good_git_repo_but_name_exists_prints_msg_to_stderr_and_exits_non_zero()
{
  local name=jj
  local url="${github_cyber_dojo}/start-points-exercises.git"
  ${exe} start-point create ${name} --git=${url} >${stdoutF} 2>${stderrF}
  assertTrue $?

  local expected_stderr="FAILED: a start-point called ${name} already exists"
  ${exe} start-point create ${name} --git=${url} >${stdoutF} 2>${stderrF}
  assertFalse $?
  assertNoStdout
  assertEqualsStderr "${expected_stderr}"

  ${exe} start-point rm ${name}
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

. ./shunit2_helpers.sh
. ./shunit2
