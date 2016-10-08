#!/bin/bash

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_up_help_prints_use_to_stdout_and_exits_zero()
{
  local expectedStdout="
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
                           https://github.com/cyber-dojo/start-points-custom.git"
  ./../cyber-dojo up help >${stdoutF} 2>${stderrF}
  local exit_status=$?
  assertTrue ${exit_status}
  assertEqualsStdout "${expectedStdout}"
  assertNoStderr
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_up_unknown_prints_terse_msg_to_stderr_and_exits_non_zero()
{
  local expectedStderr="FAILED: unknown argument [salmon]"
  ./../cyber-dojo up salmon >${stdoutF} 2>${stderrF}
  local exit_status=$?
  assertFalse ${exit_status}
  assertNoStdout
  assertEqualsStderr "${expectedStderr}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_up_unknowns_prints_terse_msg_to_left_of_equal_to_stderr_and_exits_non_zero()
{
  local expectedStderr="FAILED: unknown argument [--spey]
FAILED: unknown argument [--tay]"
  ./../cyber-dojo up --spey=A --tay=B >${stdoutF} 2>${stderrF}
  local exit_status=$?
  assertFalse ${exit_status}
  assertNoStdout
  assertEqualsStderr "${expectedStderr}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_up_missingLanguages_prints_terse_msg_to_sterr_and_exits_non_zero()
{
  local expectedStderr='FAILED: missing argument value --languages=[???]'
  ./../cyber-dojo up --languages= >${stdoutF} 2>${stderrF}
  local exit_status=$?
  assertFalse ${exit_status}
  assertNoStdout
  assertEqualsStderr "${expectedStderr}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_up_missingCustom_prints_terse_msg_to_sterr_and_exits_non_zero()
{
  local expectedStderr='FAILED: missing argument value --custom=[???]'
  ./../cyber-dojo up --custom= >${stdoutF} 2>${stderrF}
  local exit_status=$?
  assertFalse ${exit_status}
  assertNoStdout
  assertEqualsStderr "${expectedStderr}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_up_missingExercises_prints_terse_msg_to_sterr_and_exits_non_zero()
{
  local expectedStderr='FAILED: missing argument value --exercises=[???]'
  ./../cyber-dojo up --exercises= >${stdoutF} 2>${stderrF}
  local exit_status=$?
  assertFalse ${exit_status}
  assertNoStdout
  assertEqualsStderr "${expectedStderr}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_up_namedLanguagesDoesNotExist_prints_terse_msg_to_sterr_and_exits_non_zero()
{
  local expectedStderr='FAILED: start-point notExist does not exist'
  ./../cyber-dojo up --exercises=notExist >${stdoutF} 2>${stderrF}
  local exit_status=$?
  assertFalse ${exit_status}
  assertNoStdout
  assertEqualsStderr "${expectedStderr}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_up_namedCustomDoesNotExist_prints_terse_msg_to_sterr_and_exits_non_zero()
{
  local expectedStderr='FAILED: start-point notExist does not exist'
  ./../cyber-dojo up --custom=notExist >${stdoutF} 2>${stderrF}
  local exit_status=$?
  assertFalse ${exit_status}
  assertNoStdout
  assertEqualsStderr "${expectedStderr}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_up_namedExercisesDoesNotExist_prints_terse_msg_to_sterr_and_exits_non_zero()
{
  local expectedStderr='FAILED: start-point notExist does not exist'
  ./../cyber-dojo up --exercises=notExist >${stdoutF} 2>${stderrF}
  local exit_status=$?
  assertFalse ${exit_status}
  assertNoStdout
  assertEqualsStderr "${expectedStderr}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# off because it relies on custom start-point existing
x_test_up_namedExercisesNotExerciseType_prints_terse_msg_to_sterr_and_exits_non_zero()
{
  local expectedStderr="FAILED: custom is not a exercises start-point (it's type from setup.json is custom)"
  ./../cyber-dojo up --exercises=custom >${stdoutF} 2>${stderrF}
  local exit_status=$?
  assertFalse ${exit_status}
  assertNoStdout
  assertEqualsStderr "${expectedStderr}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

. ./shunit2_helpers.sh
. ./shunit2
