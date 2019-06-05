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
  line1='Creates a cyber-dojo start-point image named <name>'
  line2='It will contain git clones of all the specified git-repo <url>s'

  assertStartPointCreate
  assertStdoutIncludes "${line1}"
  assertStdoutIncludes "${line2}"
  assertNoStderr

  assertStartPointCreate --help
  assertStdoutIncludes "${line1}"
  assertStdoutIncludes "${line2}"
  assertNoStderr

  assertStartPointCreate -h
  assertStdoutIncludes "${line1}"
  assertStdoutIncludes "${line2}"
  assertNoStderr
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test___failure() { :; }

test_____name_first_letter()
{
  local name=jj1
  local readonly bad_url=+bad
  refuteStartPointCreate ${name} --exercises ${bad_url}
  assertNoStdout
  assertStderrIncludes 'ERROR: bad git clone <url>'
  assertStderrIncludes "--exercises ${bad_url}"
  assertStderrIncludes "fatal: repository '${bad_url}' does not exist"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____name_second_letter()
{
  local name=jj2
  local readonly bad_url=b+ad
  refuteStartPointCreate ${name} --exercises ${bad_url}
  assertNoStdout
  assertStderrIncludes 'ERROR: bad git clone <url>'
  assertStderrIncludes "--exercises ${bad_url}"
  assertStderrIncludes "fatal: repository '${bad_url}' does not exist"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____name_one_letter_name()
{
  local name=jj3
  local readonly bad_url=b
  refuteStartPointCreate ${name} --exercises ${bad_url}
  assertNoStdout
  assertStderrIncludes 'ERROR: bad git clone <url>'
  assertStderrIncludes "--exercises ${bad_url}"
  assertStderrIncludes "fatal: repository '${bad_url}' does not exist"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____unknown_arg()
{
  local readonly arg='--where'
  refuteStartPointCreate jj ${arg}=tay
  assertNoStdout
  assertStderrEquals "ERROR: <image-name> must be followed by one of --custom/--exercises/--languages"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____unknown_args()
{
  local readonly arg1='--where'
  local readonly arg2='--there'
  refuteStartPointCreate jj ${arg1}=tay ${arg2}=x
  assertNoStdout
  assertStderrEquals "ERROR: <image-name> must be followed by one of --custom/--exercises/--languages"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

. ${MY_DIR}/shunit2_helpers.sh
. ${MY_DIR}/shunit2
