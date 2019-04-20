#!/bin/bash

# Some of these tests will fail
#   o) if you do not have a network connection
#   o) if github is down

MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"

. ${MY_DIR}/cyber_dojo_helpers.sh

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_START_POINT_CREATE() { :; }

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test___success() { :; }

test_____help_arg_prints_use()
{
  line1='$ ./cyber-dojo start-point create <name> --custom    <url>...'
  line2='$ ./cyber-dojo start-point create <name> --exercises <url>...'
  line3='$ ./cyber-dojo start-point create <name> --languages <url>...'

  assertStartPointCreate
  assertStdoutIncludes "${line1}"
  assertStdoutIncludes "${line2}"
  assertStdoutIncludes "${line3}"
  assertNoStderr

  assertStartPointCreate --help
  assertStdoutIncludes "${line1}"
  assertStdoutIncludes "${line2}"
  assertStdoutIncludes "${line3}"
  assertNoStderr

  assertStartPointCreate -h
  assertStdoutIncludes "${line1}"
  assertStdoutIncludes "${line2}"
  assertStdoutIncludes "${line3}"
  assertNoStderr
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test___failure() { :; }

test_____name_first_letter()
{
  local name=jj
  local readonly arg=+bad
  refuteStartPointCreate "${name}" --exercises ${arg}
  assertNoStdout
  assertStderrIncludes 'ERROR: bad git clone <url>'
  assertStderrIncludes '--exercises +bad'
  assertStderrIncludes "fatal: repository '+bad' does not exist"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

xtest_____name_second_letter()
{
  local readonly arg=b+ad
  refuteStartPointCreate ${arg}
  assertNoStdout
  assertStderrEquals "ERROR: ${arg} is an illegal NAME"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

xtest_____name_one_letter_name()
{
  local readonly name=b
  refuteStartPointCreate ${name}
  assertNoStdout
  assertStderrEquals "FAILED: ${name} is an illegal NAME"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

xtest_____dir_and_git_args()
{
  refuteStartPointCreate jj --dir=where --git=url
  assertNoStdout
  assertStderrEquals 'ERROR: specify ONE of --git= / --dir= / --list='
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

xtest_____unknown_arg()
{
  local readonly arg='--where'
  refuteStartPointCreate jj ${arg}=tay
  assertNoStdout
  assertStderrEquals "ERROR: unknown argument [${arg}]"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

xtest_____unknown_args()
{
  local readonly arg1='--where'
  local readonly arg2='--there'
  refuteStartPointCreate jj ${arg1}=tay ${arg2}=x
  assertNoStdout
  assertStderrIncludes "ERROR: unknown argument [${arg1}]"
  assertStderrIncludes "ERROR: unknown argument [${arg2}]"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

. ${MY_DIR}/shunit2_helpers.sh
. ${MY_DIR}/shunit2
