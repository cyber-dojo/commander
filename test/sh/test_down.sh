#!/bin/bash

. ./cyber_dojo_helpers.sh

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_DOWN() { :; }

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test___success() { :; }

test_____help_arg_prints_use()
{
  local expected_stdout="
Use: cyber-dojo down

Stops and removes docker containers created with 'up'"
  assertDown --help
  assertStdoutEquals "${expected_stdout}"
  assertNoStderr
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____no_args_stops_and_removes_server_containers()
{
  assertUp
  assertDown

  declare -a services=(
    collector
    differ
    grafana
    nginx
    prometheus
    runner
    runner-stateless
    storer
    web
    zipper
  )
  for service in "${services[@]}"
  do
    assertStderrIncludes "Stopping cyber-dojo-${service}"
    assertStderrIncludes "Removing cyber-dojo-${service}"
  done
  assertNoStdout

  assertStartPointRm languages
  assertStartPointRm exercises
  assertStartPointRm custom
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test___failure() { :; }

test_____unknown_arg()
{
  local arg=salmon
  refuteDown ${arg}
  assertNoStdout
  assertStderrEquals "FAILED: unknown argument [${arg}]"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____unknown_args()
{
  local arg1=salmon
  local arg2=parr
  refuteDown ${arg1} ${arg2}
  assertNoStdout
  assertStderrIncludes "FAILED: unknown argument [${arg1}]"
  assertStderrIncludes "FAILED: unknown argument [${arg2}]"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

. ./shunit2_helpers.sh
. ./shunit2
