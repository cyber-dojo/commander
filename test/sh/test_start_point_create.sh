#!/bin/bash

# Some of these tests will fail
#   o) if you do not have a network connection
#   o) if github is down

. ./cyber_dojo_helpers.sh

test_start_point_create_Help_prints_use_to_stdout_and_exits_zero()
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
  local exit_status=$?
  assertTrue ${exit_status}
  assertEqualsStdout "${expected_stdout}"
  assertNoStderr
  ${exe} start-point create --help >${stdoutF} 2>${stderrF}
  local exit_status=$?
  assertTrue ${exit_status}
  assertEqualsStdout "${expected_stdout}"
  assertNoStderr
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_start_point_create_IllegalName_first_letter_prints_msg_to_stderr_and_exits_non_zero()
{
  local expected_stderr="FAILED: +bad is an illegal NAME"
  ${exe} start-point create +bad >${stdoutF} 2>${stderrF}
  local exit_status=$?
  assertFalse ${exit_status}
  assertNoStdout
  assertEqualsStderr "${expected_stderr}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_start_point_create_IllegalName_second_letter_prints_msg_to_stderr_and_exits_non_zero()
{
  local expected_stderr="FAILED: b+ad is an illegal NAME"
  ${exe} start-point create b+ad >${stdoutF} 2>${stderrF}
  local exit_status=$?
  assertFalse ${exit_status}
  assertNoStdout
  assertEqualsStderr "${expected_stderr}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_start_point_create_IllegalName_one_letter_name_prints_msg_to_stderr_and_exits_non_zero()
{
  local expected_stderr="FAILED: b is an illegal NAME"
  ${exe} start-point create b >${stdoutF} 2>${stderrF}
  local exit_status=$?
  assertFalse ${exit_status}
  assertNoStdout
  assertEqualsStderr "${expected_stderr}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_start_point_create_name_UnknownArg_prints_msg_to_stderr_and_exits_non_zero()
{
  local expected_stderr="FAILED: unknown argument [--where]"
  local name=jj
  ${exe} start-point create ${name} --where=tay >${stdoutF} 2>${stderrF}
  local exit_status=$?
  assertFalse ${exit_status}
  assertNoStdout
  assertEqualsStderr "${expected_stderr}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_start_point_create_name_UnknownArgs_prints_msg_to_stderr_and_exits_non_zero()
{
  local expected_stderr="FAILED: unknown argument [--where]
FAILED: unknown argument [--there]"
  local name=jj
  ${exe} start-point create ${name} --where=tay --there=x >${stdoutF} 2>${stderrF}
  local exit_status=$?
  assertFalse ${exit_status}
  assertNoStdout
  assertEqualsStderr "${expected_stderr}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_start_point_create_name_DirAndGit_args_prints_msg_to_stderr_and_exits_non_zero()
{
  local expected_stderr="FAILED: specify --git=... OR --dir=... but not both"
  local name=jj
  ${exe} start-point create ${name} --dir=where --git=url >${stdoutF} 2>${stderrF}
  local exit_status=$?
  assertFalse ${exit_status}
  assertNoStdout
  assertEqualsStderr "${expected_stderr}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

github_cyber_dojo='https://github.com/cyber-dojo'

test_start_point_create_fromGitRepoWithNewName_prints_nothing_and_exits_zero()
{
  local name=jj
  local url="${github_cyber_dojo}/start-points-exercises.git"
  ${exe} start-point create ${name} --git=${url} >${stdoutF} 2>${stderrF}
  local exit_status=$?
  assertTrue ${exit_status}
  assertNoStdout
  assertNoStderr
  ${exe} start-point rm ${name}
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_start_point_create_fromGitRepoButNameExists_prints_msg_to_stderr_and_exits_non_zero()
{
  local name=jj
  local url="${github_cyber_dojo}/start-points-exercises.git"
  ${exe} start-point create ${name} --git=${url} >${stdoutF} 2>${stderrF}
  local exit_status=$?
  assertTrue ${exit_status}

  local expected_stderr="FAILED: a start-point called ${name} already exists"
  ${exe} start-point create ${name} --git=${url} >${stdoutF} 2>${stderrF}
  local exit_status=$?
  assertFalse ${exit_status}
  assertNoStdout
  assertEqualsStderr "${expected_stderr}"

  ${exe} start-point rm ${name}
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_start_point_create_fromDirWithBadContent_prints_msg_to_stderr_and_exits_non_zero()
{
  local bad_dir=./../rb/example_start_points/bad_custom
  ${exe} start-point create bad --dir=${bad_dir} >${stdoutF} 2>${stderrF}
  local exit_status=$?
  # TODO: lose /data/ from output?
  # TODO: secretly pass host path to commander?
  local expected_stderr="FAILED...
/data/Tennis/C#/manifest.json: Xfilename_extension: unknown key"
  assertFalse ${exit_status}
  assertNoStdout
  assertEqualsStderr "${expected_stderr}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

. ./shunit2_helpers.sh
. ./shunit2
