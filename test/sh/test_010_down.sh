#!/bin/bash

MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"
. ${MY_DIR}/cyber_dojo_helpers.sh

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_DOWN() { :; }

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test___success() { :; }

test_____help_arg_prints_use()
{
  local -r expected_stdout="
Use: cyber-dojo down

Stops and removes docker containers created with 'up'"

  assertDown -h
  assertStdoutEquals "${expected_stdout}"
  assertNoStderr

  assertDown --help
  assertStdoutEquals "${expected_stdout}"
  assertNoStderr
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____no_args_stops_and_removes_server_containers()
{
  local -r custom_name=test_down_custom
  assertStartPointCreate ${custom_name}    --custom $(custom_urls)
  local -r exercises_name=test_down_exercises
  assertStartPointCreate ${exercises_name} --exercises $(exercises_urls)
  local -r languages_name=test_down_languages
  assertStartPointCreate ${languages_name} --languages $(languages_urls)

  assertUp --custom=${custom_name} \
           --exercises=${exercises_name} \
           --languages=${languages_name}

  assertDown
  refuteStdoutIncludes 'variable is not set. Defaulting to a blank string.'
  for service in custom_start_points exercises_start_points languages_start_points "${service_names[@]}"
  do
    assertStdoutIncludes "Container cyber_dojo_${service}  Stopping"
    assertStdoutIncludes "Container cyber_dojo_${service}  Removing"
  done
  assertNoStderr

  assertStartPointRm ${custom_name}
  assertStartPointRm ${exercises_name}
  assertStartPointRm ${languages_name}
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test___failure() { :; }

test_____unknown_arg()
{
  local -r arg=salmon
  refuteDown ${arg}
  assertNoStdout
  assertStderrEquals "FAILED: unknown argument [${arg}]"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____unknown_args()
{
  local -r arg1=salmon
  local -r arg2=parr
  refuteDown ${arg1} ${arg2}
  assertNoStdout
  assertStderrIncludes "FAILED: unknown argument [${arg1}]"
  assertStderrIncludes "FAILED: unknown argument [${arg2}]"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

. ${MY_DIR}/shunit2_helpers.sh
. ${MY_DIR}/shunit2
