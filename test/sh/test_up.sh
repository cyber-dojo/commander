#!/bin/bash

. ./cyber_dojo_helpers.sh

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_UP() { :; }

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test___SUCCESS_exits_zero() { :; }

test_____no_args_uses_default_start_points_and_creates_containers()
{
  assertUp
  assertStdoutIncludes 'Using --languages=languages'
  assertStdoutIncludes 'Using --exercises=exercises'
  assertStdoutIncludes 'Using --custom=custom'
  assertStdoutIncludes 'Using --port=80'
  assertStdoutIncludes 'Creating cyber-dojo-collector'
  assertStdoutIncludes 'Creating cyber-dojo-differ'
  assertStdoutIncludes 'Creating cyber-dojo-grafana'
  assertStdoutIncludes 'Creating cyber-dojo-prometheus'
  assertStdoutIncludes 'Creating cyber-dojo-nginx'
  assertStdoutIncludes 'Creating cyber-dojo-runner'
  assertStdoutIncludes 'Creating cyber-dojo-runner-stateless'
  assertStdoutIncludes 'Creating cyber-dojo-storer'
  assertStdoutIncludes 'Creating cyber-dojo-web'
  assertStdoutIncludes 'Creating cyber-dojo-zipper'
  assertNoStderr
  assertDown
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____help_arg_prints_use_to_stdout()
{
  local expected_stdout="
Use: cyber-dojo up [OPTIONS]

Creates and starts the cyber-dojo server using named/default start-points

  --languages=START-POINT  Specify the languages start-point.
                           Defaults to a start-point named 'languages' created from
                           https://github.com/cyber-dojo/start-points-languages.git

  --exercises=START-POINT  Specify the exercises start-point.
                           Defaults to a start-point named 'exercises' created from
                           https://github.com/cyber-dojo/start-points-exercises.git

  --custom=START-POINT     Specify the custom start-point.
                           Defaults to a start-point named 'custom' created from
                           https://github.com/cyber-dojo/start-points-custom.git

  --port=LISTEN-PORT       Specify port to listen on.
                           Defaults to 80"

  assertUp --help
  assertEqualsStdout "${expected_stdout}"
  assertNoStderr
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____prints_msg_naming_default_start_points_and_port()
{
  assertUp
  assertStdoutIncludes 'Using --languages=languages'
  assertStdoutIncludes 'Using --exercises=exercises'
  assertStdoutIncludes 'Using --custom=custom'
  assertStdoutIncludes 'Using --port=80'
  assertNoStderr
  assertDown
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____custom_start_point_prints_msg_saying_its_being_used()
{
  local name=jj
  local url="${github_cyber_dojo}/start-points-custom.git"
  assertStartPointCreateGit ${name} ${url}
  assertUp --custom=${name}
  assertStdoutIncludes 'Using --languages=languages'
  assertStdoutIncludes 'Using --exercises=exercises'
  assertStdoutIncludes "Using --custom=${name}"
  assertStdoutIncludes 'Using --port=80'
  assertNoStderr
  assertDown
  assertStartPointRm ${name}
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____custom_port_prints_msg_saying_its_being_used()
{
  local port=8462
  assertUp --port=${port}
  assertStdoutIncludes 'Using --languages=languages'
  assertStdoutIncludes 'Using --exercises=exercises'
  assertStdoutIncludes 'Using --custom=custom'
  assertStdoutIncludes "Using --port=${port}"
  assertNoStderr
  assertDown
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test___FAILURE_prints_msg_to_stderr_and_exits_non_zero() { :; }

test_____unknown_arg()
{
  refuteUp salmon
  assertNoStdout
  assertEqualsStderr 'FAILED: unknown argument [salmon]'
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____unknown_args()
{
  refuteUp --spey=A --tay=B
  assertNoStdout
  assertStderrIncludes 'FAILED: unknown argument [--spey]'
  assertStderrIncludes 'FAILED: unknown argument [--tay]'
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____missing_languages()
{
  refuteUp --languages=
  assertNoStdout
  assertEqualsStderr 'FAILED: missing argument value --languages=[???]'
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____missing_custom()
{
  refuteUp --custom=
  assertNoStdout
  assertEqualsStderr 'FAILED: missing argument value --custom=[???]'
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____missing_exercises()
{
  refuteUp --exercises=
  assertNoStdout
  assertEqualsStderr 'FAILED: missing argument value --exercises=[???]'
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____missing_port()
{
  refuteUp --port=
  assertNoStdout
  assertEqualsStderr 'FAILED: missing argument value --port=[???]'
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____named_languages_does_not_exist()
{
  refuteUp --exercises=notExist
  assertNoStdout
  assertEqualsStderr 'FAILED: start-point notExist does not exist'
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____named_custom_does_not_exist()
{
  refuteUp --custom=notExist
  assertNoStdout
  assertEqualsStderr 'FAILED: start-point notExist does not exist'
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____named_exercises_does_not_exist()
{
  refuteUp --exercises=notExist
  assertNoStdout
  assertEqualsStderr 'FAILED: start-point notExist does not exist'
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____named_exercises_is_not_exercise_type()
{
  local url=https://github.com/cyber-dojo/start-points-custom.git
  assertStartPointCreateGit jj ${url}
  refuteUp --exercises=jj
  assertStartPointRm jj
  assertNoStdout
  assertEqualsStderr "FAILED: jj is not a exercises start-point (it's type from setup.json is custom)"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

. ./shunit2_helpers.sh
. ./shunit2

