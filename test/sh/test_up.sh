#!/bin/bash

. ./cyber_dojo_helpers.sh

test_up_uses_default_start_points_and_creates_containers()
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

test_up_help_prints_use_to_stdout_and_exits_zero()
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

test_up_unknown_arg_prints_msg_to_stderr_and_exits_non_zero()
{
  local expected_stderr="FAILED: unknown argument [salmon]"
  ${exe} up salmon >${stdoutF} 2>${stderrF}
  assertFalse $?
  assertNoStdout
  assertEqualsStderr "${expected_stderr}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_up_unknown_args_prints_msg_to_left_of_equal_to_stderr_and_exits_non_zero()
{
  local expected_stderr="FAILED: unknown argument [--spey]
FAILED: unknown argument [--tay]"
  ${exe} up --spey=A --tay=B >${stdoutF} 2>${stderrF}
  assertFalse $?
  assertNoStdout
  assertEqualsStderr "${expected_stderr}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_up_missing_languages_prints_msg_to_sterr_and_exits_non_zero()
{
  local expected_stderr='FAILED: missing argument value --languages=[???]'
  ${exe} up --languages= >${stdoutF} 2>${stderrF}
  assertFalse $?
  assertNoStdout
  assertEqualsStderr "${expected_stderr}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_up_missing_custom_prints_msg_to_sterr_and_exits_non_zero()
{
  local expected_stderr='FAILED: missing argument value --custom=[???]'
  ${exe} up --custom= >${stdoutF} 2>${stderrF}
  assertFalse $?
  assertNoStdout
  assertEqualsStderr "${expected_stderr}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_up_missing_exercises_prints_msg_to_sterr_and_exits_non_zero()
{
  local expected_stderr='FAILED: missing argument value --exercises=[???]'
  ${exe} up --exercises= >${stdoutF} 2>${stderrF}
  assertFalse $?
  assertNoStdout
  assertEqualsStderr "${expected_stderr}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_up_missing_port_prints_msg_to_sterr_and_exits_non_zero()
{
  local expected_stderr='FAILED: missing argument value --port=[???]'
  ${exe} up --port= >${stdoutF} 2>${stderrF}
  assertFalse $?
  assertNoStdout
  assertEqualsStderr "${expected_stderr}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_up_named_languages_does_not_exist_prints_msg_to_sterr_and_exits_non_zero()
{
  local expected_stderr='FAILED: start-point notExist does not exist'
  ${exe} up --exercises=notExist >${stdoutF} 2>${stderrF}
  assertFalse $?
  assertNoStdout
  assertEqualsStderr "${expected_stderr}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_up_named_custom_does_not_exist_prints_msg_to_sterr_and_exits_non_zero()
{
  local expected_stderr='FAILED: start-point notExist does not exist'
  ${exe} up --custom=notExist >${stdoutF} 2>${stderrF}
  assertFalse $?
  assertNoStdout
  assertEqualsStderr "${expected_stderr}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_up_named_exercises_does_not_exist_prints_msg_to_sterr_and_exits_non_zero()
{
  local expected_stderr='FAILED: start-point notExist does not exist'
  ${exe} up --exercises=notExist >${stdoutF} 2>${stderrF}
  assertFalse $?
  assertNoStdout
  assertEqualsStderr "${expected_stderr}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_up_named_exercises_is_not_exercise_type_prints_msg_to_sterr_and_exits_non_zero()
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

test_up_prints_msg_naming_default_start_points_and_port_exits_zero()
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

test_up_custom_start_point_prints_msg_saying_its_being_used_exits_zero()
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

test_up_custom_port_prints_msg_saying_its_being_used_exits_zero()
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

. ./shunit2_helpers.sh
. ./shunit2

