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

test_____extra_arg()
{
  local arg=extra
  refuteDown ${arg}
  assertNoStdout
  assertStderrEquals "FAILED: unknown argument [${arg}]"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____extra_args()
{
  local extra1=salmon
  local extra2=parr
  refuteDown ${extra1} ${extra2}
  assertNoStdout
  assertStderrIncludes "FAILED: unknown argument [${extra1}]"
  assertStderrIncludes "FAILED: unknown argument [${extra2}]"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

. ./shunit2_helpers.sh
. ./shunit2
