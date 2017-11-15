#!/bin/bash

MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"

. ${MY_DIR}/cyber_dojo_helpers.sh

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_START_POINT_RM() { :; }

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test___success() { :; }

test_____no_arg_or_help_arg_prints_use()
{
  local expected_stdout="
Use: cyber-dojo start-point rm NAME

Removes a start-point created with the [cyber-dojo start-point create] command"
  assertStartPointRm
  assertStdoutEquals "${expected_stdout}"
  assertNoStderr

  assertStartPointRm --help
  assertStdoutEquals "${expected_stdout}"
  assertNoStderr
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____removes_previously_created_start_point()
{
  local name=good
  local good_dir=`absPath ${MY_DIR}/../rb/example_start_points/custom`
  assertStartPointCreate ${name} --dir=${good_dir}
  assertStartPointExists ${name}
  assertStartPointRm ${name}
  assertNoStdout
  assertNoStderr
  refuteStartPointExists ${name}
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test___failure() { :; }

test_____named_start_point_does_not_exist()
{
  local name=salmon
  refuteStartPointExists ${name}
  refuteStartPointRm ${name}
  assertNoStdout
  assertStderrEquals "FAILED: ${name} does not exist."
  refuteStartPointExists ${name}
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____named_start_point_is_not_a_cyber_dojo_volume()
{
  local name=salmon
  docker volume create --name ${name} > /dev/null; assertEquals 0 $?;
  refuteStartPointRm ${name}
  docker volume rm ${name} > /dev/null; assertEquals 0 $?;
  assertNoStdout
  assertStderrEquals "FAILED: ${name} is not a cyber-dojo start-point."
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

. ${MY_DIR}/shunit2_helpers.sh
. ${MY_DIR}/shunit2
