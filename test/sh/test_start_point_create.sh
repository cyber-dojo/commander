#!/bin/bash

# Some of these tests will fail
#   o) if you do not have a network connection
#   o) if github is down

. ./cyber_dojo_helpers.sh

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_START_POINT_CREATE() { :; }

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test___SUCCESS_exits_zero() { :; }

test_____help_arg_prints_use_to_stdout()
{
  local expected_stdout="
Use: cyber-dojo start-point create NAME --list=FILE
Creates a start-point named NAME from the URLs listed in FILE

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

test___FAILURE_prints_msg_to_stderr_and_exits_non_zero() { :; }

test_____illegal_name_first_letter()
{
  local expected_stderr="FAILED: +bad is an illegal NAME"
  ${exe} start-point create +bad >${stdoutF} 2>${stderrF}
  assertFalse $?
  assertNoStdout
  assertEqualsStderr "${expected_stderr}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____illegal_name_second_letter()
{
  local expected_stderr="FAILED: b+ad is an illegal NAME"
  ${exe} start-point create b+ad >${stdoutF} 2>${stderrF}
  assertFalse $?
  assertNoStdout
  assertEqualsStderr "${expected_stderr}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____illegal_name_one_letter_name()
{
  local expected_stderr="FAILED: b is an illegal NAME"
  ${exe} start-point create b >${stdoutF} 2>${stderrF}
  assertFalse $?
  assertNoStdout
  assertEqualsStderr "${expected_stderr}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____unknown_arg()
{
  local expected_stderr="FAILED: unknown argument [--where]"
  ${exe} start-point create jj --where=tay >${stdoutF} 2>${stderrF}
  assertFalse $?
  assertNoStdout
  assertEqualsStderr "${expected_stderr}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____unknown_args()
{
  local expected_stderr="FAILED: unknown argument [--where]
FAILED: unknown argument [--there]"
  ${exe} start-point create jj --where=tay --there=x >${stdoutF} 2>${stderrF}
  assertFalse $?
  assertNoStdout
  assertEqualsStderr "${expected_stderr}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____dir_and_git_args()
{
  local expected_stderr="FAILED: specify ONE of --git= / --dir= / --list="
  ${exe} start-point create jj --dir=where --git=url >${stdoutF} 2>${stderrF}
  assertFalse $?
  assertNoStdout
  assertEqualsStderr "${expected_stderr}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

. ./shunit2_helpers.sh
. ./shunit2
