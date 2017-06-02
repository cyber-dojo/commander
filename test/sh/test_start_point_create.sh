#!/bin/bash

# Some of these tests will fail
#   o) if you do not have a network connection
#   o) if github is down

. ./cyber_dojo_helpers.sh

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_START_POINT_CREATE() { :; }

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test___success() { :; }

test_____help_arg_prints_use()
{
  local expected_stdout="
Use: cyber-dojo start-point create NAME --list=URL|FILE
Creates a start-point named NAME from git-clones of all the URLs listed in URL|FILE

Use: cyber-dojo start-point create NAME --git=URL
Creates a start-point named NAME from a git clone of URL

Use: cyber-dojo start-point create NAME --dir=DIR
Creates a start-point named NAME from a copy of DIR

NAME's first letter must be [a-zA-Z0-9]
NAME's remaining letters must be [a-zA-Z0-9_.-]
NAME must be at least two letters long"

  assertStartPointCreate
  assertStdoutEquals "${expected_stdout}"
  assertNoStderr

  assertStartPointCreate --help
  assertStdoutEquals "${expected_stdout}"
  assertNoStderr
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test___failure() { :; }

test_____name_first_letter()
{
  local arg=+bad
  refuteStartPointCreate ${arg}
  assertNoStdout
  assertStderrEquals "FAILED: ${arg} is an illegal NAME"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____name_second_letter()
{
  local arg=b+ad
  refuteStartPointCreate ${arg}
  assertNoStdout
  assertStderrEquals "FAILED: ${arg} is an illegal NAME"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____name_one_letter_name()
{
  local name=b
  refuteStartPointCreate ${name}
  assertNoStdout
  assertStderrEquals "FAILED: ${name} is an illegal NAME"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____dir_and_git_args()
{
  refuteStartPointCreate jj --dir=where --git=url
  assertNoStdout
  assertStderrEquals 'FAILED: specify ONE of --git= / --dir= / --list='
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____unknown_arg()
{
  local arg='--where'
  refuteStartPointCreate jj ${arg}=tay
  assertNoStdout
  assertStderrEquals "FAILED: unknown argument [${arg}]"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____unknown_args()
{
  local arg1='--where'
  local arg2='--there'
  refuteStartPointCreate jj ${arg1}=tay ${arg2}=x
  assertNoStdout
  assertStderrIncludes "FAILED: unknown argument [${arg1}]"
  assertStderrIncludes "FAILED: unknown argument [${arg2}]"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

. ./shunit2_helpers.sh
. ./shunit2
