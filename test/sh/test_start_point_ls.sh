#!/bin/bash

MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"

. ${MY_DIR}/cyber_dojo_helpers.sh

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_START_POINT_LS() { :; }

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test___success() { :; }

test_____help_arg_prints_use()
{
  local readonly expected_stdout="
Use: cyber-dojo start-point ls [-q|--quiet]

Lists, in JSON form, the name and type of all cyber-dojo start-points.

-q|--quiet     Only display start-point names"
  assertStartPointLs --help
  assertStdoutEquals "${expected_stdout}"
  assertNoStderr
}

test_____no_args_prints_nothing_when_no_images()
{
  assertStartPointLs
  assertNoStdout
  assertNoStderr
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____quiet_arg_prints_nothing_when_no_images()
{
  assertStartPointLs --quiet
  assertNoStdout
  assertNoStderr
  assertStartPointLs -q
  assertNoStdout
  assertNoStderr
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____quiet_arg_prints_just_names_when_images_exist()
{
  local readonly name=jj
  local readonly url="${github_cyber_dojo}/start-points-exercises.git"
  assertStartPointCreate ${name} --exercises ${url}
  assertStartPointLs --quiet
  assertStdoutIncludes "${name}"
  assertNoStderr
  assertStartPointLs -q
  assertStdoutIncludes "${name}"
  assertNoStderr

  assertStartPointRm ${name}
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

x_test_____no_arg_prints_heading_and_names_types_sources()
{
  local readonly name=jj
  local readonly url="${github_cyber_dojo}/start-points-exercises.git"
  assertStartPointCreate ${name} --exercises ${url}
  assertStartPointLs
  assertStdoutIncludes 'NAME   TYPE        SRC'
  # TODO: fix this. SRC is missing
  assertStdoutIncludes 'jj     exercises'
  #assertStdoutIncludes 'jj     exercises   https://github.com/cyber-dojo/start-points-exercises.git'
  assertNoStderr

  assertStartPointRm ${name}
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test___failure() { :; }

test_____unknown_arg()
{
  local readonly arg=salmo
  refuteStartPointLs ${arg}
  assertNoStdout
  assertStderrEquals "ERROR: unknown argument [${arg}]"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____unknown_args()
{
  local readonly arg1=salmon
  local readonly arg2=spey
  refuteStartPointLs ${arg1} ${arg2}
  assertNoStdout
  assertStderrIncludes "ERROR: unknown argument [${arg1}]"
  assertStderrIncludes "ERROR: unknown argument [${arg2}]"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

. ${MY_DIR}/shunit2_helpers.sh
. ${MY_DIR}/shunit2
