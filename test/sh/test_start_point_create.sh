#!/bin/bash

# Some of these tests will fail
#   o) if you do not have a network connection
#   o) if github is down

. ./cyber_dojo_helpers.sh

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_CYBER_DOJO_START_POINT_CREATE()
{
  :
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_help_arg_prints_use_to_stdout_and_exits_zero()
{
  local expected_stdout="
Use: cyber-dojo start-point create NAME --git=URL
Creates a start-point named NAME from a git clone of URL

Use: cyber-dojo start-point create NAME --dir=DIR
Creates a start-point named NAME from a copy of DIR

NAME's first letter must be [a-zA-Z0-9]
NAME's remaining letters must be [a-zA-Z0-9_.-]
NAME must be at least two letters long"
  ${exe} start-point create >${stdoutF} 2>${stderrF}
  assertTrue $?
  assertEqualsStdout "${expected_stdout}"
  assertNoStderr
  ${exe} start-point create --help >${stdoutF} 2>${stderrF}
  assertTrue $?
  assertEqualsStdout "${expected_stdout}"
  assertNoStderr
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_illegal_name_first_letter_prints_msg_to_stderr_and_exits_non_zero()
{
  local expected_stderr="FAILED: +bad is an illegal NAME"
  ${exe} start-point create +bad >${stdoutF} 2>${stderrF}
  assertFalse $?
  assertNoStdout
  assertEqualsStderr "${expected_stderr}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_illegal_name_second_letter_prints_msg_to_stderr_and_exits_non_zero()
{
  local expected_stderr="FAILED: b+ad is an illegal NAME"
  ${exe} start-point create b+ad >${stdoutF} 2>${stderrF}
  assertFalse $?
  assertNoStdout
  assertEqualsStderr "${expected_stderr}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_illegal_name_one_letter_name_prints_msg_to_stderr_and_exits_non_zero()
{
  local expected_stderr="FAILED: b is an illegal NAME"
  ${exe} start-point create b >${stdoutF} 2>${stderrF}
  assertFalse $?
  assertNoStdout
  assertEqualsStderr "${expected_stderr}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_unknown_arg_prints_msg_to_stderr_and_exits_non_zero()
{
  local expected_stderr="FAILED: unknown argument [--where]"
  ${exe} start-point create jj --where=tay >${stdoutF} 2>${stderrF}
  assertFalse $?
  assertNoStdout
  assertEqualsStderr "${expected_stderr}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_unknown_args_prints_msg_to_stderr_and_exits_non_zero()
{
  local expected_stderr="FAILED: unknown argument [--where]
FAILED: unknown argument [--there]"
  ${exe} start-point create jj --where=tay --there=x >${stdoutF} 2>${stderrF}
  assertFalse $?
  assertNoStdout
  assertEqualsStderr "${expected_stderr}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_dir_and_git_args_prints_msg_to_stderr_and_exits_non_zero()
{
  local expected_stderr="FAILED: specify --git=... OR --dir=... but not both"
  ${exe} start-point create jj --dir=where --git=url >${stdoutF} 2>${stderrF}
  assertFalse $?
  assertNoStdout
  assertEqualsStderr "${expected_stderr}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_from_git_repo_with_new_name_prints_nothing_and_exits_zero()
{
  local name=jj
  local url="${github_cyber_dojo}/start-points-exercises.git"
  ${exe} start-point create ${name} --git=${url} >${stdoutF} 2>${stderrF}
  assertTrue $?
  assertNoStdout
  assertNoStderr
  ${exe} start-point rm ${name}
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_from_git_repo_but_name_exists_prints_msg_to_stderr_and_exits_non_zero()
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

test_from_dir_with_bad_content_prints_msg_to_stderr_and_exits_non_zero()
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
