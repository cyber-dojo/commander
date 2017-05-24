#!/bin/bash

. ./cyber_dojo_helpers.sh

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_START_POINT_LS() { :; }

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test___SUCCESS_exits_zero() { :; }

test_____help_arg_prints_use_to_stdout()
{
  local expected_stdout="
Use: cyber-dojo start-point [OPTIONS] ls

Lists the name, type, and source of all cyber-dojo start-points

  --quiet     Only display start-point names"
  assertStartPointLs --help
  assertStdoutEquals "${expected_stdout}"
  assertNoStderr
}

test_____no_args_prints_nothing_when_no_volumes()
{
  assertStartPointLs
  assertNoStdout
  assertNoStderr
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____quiet_arg_prints_nothing_when_no_volumes()
{
  assertStartPointLs --quiet
  assertNoStdout
  assertNoStderr
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____quiet_arg_prints_just_names_when_volumes_exist()
{
  local name=jj
  local url="${github_cyber_dojo}/start-points-exercises.git"
  assertStartPointCreate ${name} --git=${url}
  assertStartPointLs --quiet
  assertStdoutEquals 'jj'
  assertNoStderr

  assertStartPointRm ${name}
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____no_arg_prints_heading_and_names_types_sources()
{
  local name=jj
  local url="${github_cyber_dojo}/start-points-exercises.git"
  assertStartPointCreate ${name} --git=${url}
  assertStartPointLs
  assertStdoutIncludes 'NAME   TYPE        SRC'
  # TODO: fix this. SRC is missing
  assertStdoutIncludes 'jj     exercises'
  #assertStdoutIncludes 'jj     exercises   https://github.com/cyber-dojo/start-points-exercises.git'
  assertNoStderr

  assertStartPointRm ${name}
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test___FAILURE_prints_msg_to_stderr_and_exits_non_zero() { :; }

test_____unknown_arg()
{
  local arg=salmo
  refuteStartPointLs ${arg}
  assertNoStdout
  assertStderrEquals "FAILED: unknown argument [${arg}]"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

. ./shunit2_helpers.sh
. ./shunit2
