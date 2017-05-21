#!/bin/bash

. ./cyber_dojo_helpers.sh

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_UP() { :; }

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test___SUCCESS_exits_zero() { :; }

test_____no_args_uses_default_start_points_and_creates_containers()
{
  ${exe} up >${stdoutF} 2>${stderrF}
  assertTrue $?
  assertStdoutIncludes 'Using start-point --languages=languages'
  assertStdoutIncludes 'Using start-point --exercises=exercises'
  assertStdoutIncludes 'Using start-point --custom=custom'
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
  ${exe} up --help >${stdoutF} 2>${stderrF}
  ${exe} up --help >${stdoutF} 2>${stderrF}
  assertTrue $?
  assertEqualsStdout "${expected_stdout}"
  assertNoStderr
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____prints_msg_naming_default_start_points_and_port()
{
  ${exe} up >${stdoutF} 2>${stderrF}
  assertTrue $?
  local expected_stdout="Using start-point --languages=languages
Using start-point --exercises=exercises
Using start-point --custom=custom
Listening on port 80"
  assertStdoutIncludes ${expected_stdout}
  assertNoStderr
  ${exe} down >${stdoutF} 2>${stderrF}
  assertTrue $?
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____custom_start_point_prints_msg_saying_its_being_used()
{
  local name=jj
  local url="${github_cyber_dojo}/start-points-custom.git"
  ${exe} start-point create ${name} --git=${url}
  assertTrue $?
  ${exe} up --custom=${name} >${stdoutF} 2>${stderrF}
  assertTrue $?

  local expected_stdout="Using start-point --languages=languages
Using start-point --exercises=exercises
Using start-point --custom=${name}
Listening on port 80"
  assertStdoutIncludes ${expected_stdout}
  assertNoStderr
  ${exe} down >${stdoutF} 2>${stderrF}
  assertTrue $?
  ${exe} start-point rm ${name} >${stdoutF} 2>${stderrF}
  assertTrue $?
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____custom_port_prints_msg_saying_its_being_used()
{
  local port=8462
  ${exe} up --port=${port} >${stdoutF} 2>${stderrF}
  assertTrue $?

  local expected_stdout="Using start-point --languages=languages
Using start-point --exercises=exercises
Using start-point --custom=custom
Listening on port ${port}"
  assertStdoutIncludes ${expected_stdout}
  assertNoStderr
  ${exe} down >${stdoutF} 2>${stderrF}
  assertTrue $?
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test___FAILURE_prints_msg_to_stderr_and_exits_non_zero() { :; }

test_____unknown_arg()
{
  local expected_stderr="FAILED: unknown argument [salmon]"
  ${exe} up salmon >${stdoutF} 2>${stderrF}
  assertFalse $?
  assertNoStdout
  assertEqualsStderr "${expected_stderr}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____unknown_args()
{
  local expected_stderr="FAILED: unknown argument [--spey]
FAILED: unknown argument [--tay]"
  ${exe} up --spey=A --tay=B >${stdoutF} 2>${stderrF}
  assertFalse $?
  assertNoStdout
  assertEqualsStderr "${expected_stderr}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____missing_languages()
{
  local expected_stderr='FAILED: missing argument value --languages=[???]'
  ${exe} up --languages= >${stdoutF} 2>${stderrF}
  assertFalse $?
  assertNoStdout
  assertEqualsStderr "${expected_stderr}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____missing_custom()
{
  local expected_stderr='FAILED: missing argument value --custom=[???]'
  ${exe} up --custom= >${stdoutF} 2>${stderrF}
  assertFalse $?
  assertNoStdout
  assertEqualsStderr "${expected_stderr}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____missing_exercises()
{
  local expected_stderr='FAILED: missing argument value --exercises=[???]'
  ${exe} up --exercises= >${stdoutF} 2>${stderrF}
  assertFalse $?
  assertNoStdout
  assertEqualsStderr "${expected_stderr}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____missing_port()
{
  local expected_stderr='FAILED: missing argument value --port=[???]'
  ${exe} up --port= >${stdoutF} 2>${stderrF}
  assertFalse $?
  assertNoStdout
  assertEqualsStderr "${expected_stderr}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____named_languages_does_not_exist()
{
  local expected_stderr='FAILED: start-point notExist does not exist'
  ${exe} up --exercises=notExist >${stdoutF} 2>${stderrF}
  assertFalse $?
  assertNoStdout
  assertEqualsStderr "${expected_stderr}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____named_custom_does_not_exist()
{
  local expected_stderr='FAILED: start-point notExist does not exist'
  ${exe} up --custom=notExist >${stdoutF} 2>${stderrF}
  assertFalse $?
  assertNoStdout
  assertEqualsStderr "${expected_stderr}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____named_exercises_does_not_exist()
{
  local expected_stderr='FAILED: start-point notExist does not exist'
  ${exe} up --exercises=notExist >${stdoutF} 2>${stderrF}
  assertFalse $?
  assertNoStdout
  assertEqualsStderr "${expected_stderr}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____named_exercises_is_not_exercise_type()
{
  local url=https://github.com/cyber-dojo/start-points-custom.git
  ${exe} start-point create jj --git=${url} >${stdoutF} 2>${stderrF}

  local expected_stderr="FAILED: jj is not a exercises start-point (it's type from setup.json is custom)"
  ${exe} up --exercises=jj >${stdoutF} 2>${stderrF}
  local exit_status=$?
  ${exe} start-point rm jj
  assertFalse ${exit_status}
  assertNoStdout
  assertEqualsStderr "${expected_stderr}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

. ./shunit2_helpers.sh
. ./shunit2

