#!/bin/bash
set -e

MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"

. ${MY_DIR}/cyber_dojo_helpers.sh

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_START_POINT_RM() { :; }

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test___success() { :; }

test_____no_arg_or_help_arg_prints_use()
{
  local readonly expected_stdout="
Use: cyber-dojo start-point rm NAME

Removes a start-point created with the [cyber-dojo start-point create] command"
  assertStartPointRm
  assertStdoutEquals "${expected_stdout}"
  assertNoStderr

  assertStartPointRm --help
  assertStdoutEquals "${expected_stdout}"
  assertNoStderr

  assertStartPointRm -h
  assertStdoutEquals "${expected_stdout}"
  assertNoStderr
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____removes_previously_created_start_point()
{
  local readonly name=good1
  assertStartPointCreate ${name} --custom $(custom_urls)
  assertStartPointExists ${name}:latest
  assertStartPointRm ${name}
  assertNoStdout
  assertNoStderr
  refuteStartPointExists ${name}
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test___failure() { :; }

test_____named_start_point_does_not_exist()
{
  local readonly name=salmon1
  refuteStartPointExists ${name}
  refuteStartPointRm ${name}
  assertNoStdout
  assertStderrEquals "ERROR: ${name} does not exist."
  refuteStartPointExists ${name}
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____named_start_point_is_not_a_cyber_dojo_image()
{
  local readonly name=cyberdojo/starter-base
  refuteStartPointRm ${name}
  assertNoStdout
  assertStderrEquals "ERROR: ${name} is not a cyber-dojo start-point image."
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____unknown_arg()
{
  local readonly name=good2
  assertStartPointCreate ${name} --custom $(custom_urls)
  local readonly arg=salmo
  refuteStartPointRm ${name} ${arg}
  assertNoStdout
  assertStderrEquals "ERROR: unknown argument [${arg}]"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____unknown_args()
{
  local readonly name=good2
  assertStartPointCreate ${name} --custom $(custom_urls)
  local readonly arg1=salmo
  local readonly arg2=leaper
  refuteStartPointRm ${name} ${arg1} ${arg2}
  assertNoStdout
  assertStderrIncludes "ERROR: unknown argument [${arg1}]"
  assertStderrIncludes "ERROR: unknown argument [${arg2}]"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

. ${MY_DIR}/shunit2_helpers.sh
. ${MY_DIR}/shunit2
