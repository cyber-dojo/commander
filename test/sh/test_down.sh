#!/bin/bash
set -ex

MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"

. ${MY_DIR}/cyber_dojo_helpers.sh

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_DOWN() { :; }

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test___success() { :; }

test_____help_arg_prints_use()
{
  local expected_stdout="
Use: cyber-dojo down

Stops and removes docker containers created with 'up'"

  assertDown -h
  assertStdoutEquals "${expected_stdout}"
  assertNoStderr

  assertDown --help
  assertStdoutEquals "${expected_stdout}"
  #assertNoStderr
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

X_test_____no_args_stops_and_removes_server_containers()
{
  local readonly custom_name=test_down_custom
  assertStartPointCreate ${custom_name}    --custom $(custom_urls)
  local readonly exercises_name=test_down_exercises
  assertStartPointCreate ${exercises_name} --exercises $(exercises_urls)
  local readonly languages_name=test_down_languages
  assertStartPointCreate ${languages_name} --languages $(languages_urls)

  assertUp --custom=${custom_name} \
           --exercises=${exercises_name} \
           --languages=${languages_name}

  assertDown

  for service in custom exercises languages "${service_names[@]}"
  do
    assertStdoutIncludes "Stopping cyber-dojo-${service}"
    assertStdoutIncludes "Removing cyber-dojo-${service}"
  done
  assertNoStderr

  assertStartPointRm ${custom_name}
  assertStartPointRm ${exercises_name}
  assertStartPointRm ${languages_name}
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test___failure() { :; }

X_test_____unknown_arg()
{
  local arg=salmon
  refuteDown ${arg}
  assertNoStdout
  assertStderrEquals "FAILED: unknown argument [${arg}]"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

X_test_____unknown_args()
{
  local arg1=salmon
  local arg2=parr
  refuteDown ${arg1} ${arg2}
  assertNoStdout
  assertStderrIncludes "FAILED: unknown argument [${arg1}]"
  assertStderrIncludes "FAILED: unknown argument [${arg2}]"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

. ${MY_DIR}/shunit2_helpers.sh
. ${MY_DIR}/shunit2
