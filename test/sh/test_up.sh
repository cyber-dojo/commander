#!/bin/bash

. ./cyber_dojo_helpers.sh

test_up_uses_default_start_points_and_creates_containers()
{
  local expectedStdoutPart1="Using start-point --languages=languages
Using start-point --exercises=exercises
Using start-point --custom=custom"

  local expectedStdoutPart2="Creating cyber-dojo-differ
Creating cyber-dojo-web
Creating cyber-dojo-nginx"

  ${exe} up >${stdoutF} 2>${stderrF}
  local exit_status=$?
  assertTrue ${exit_status}
  local stdout="`cat ${stdoutF}`"
  if [[ "${stdout}" != *"${expectedStdoutPart1}"* ]]; then
    fail "expected stdout to include ${expectedStdoutPart1}"
  fi
  if [[ "${stdout}" != *"${expectedStdoutPart2}"* ]]; then
    fail "expected stdout to include ${expectedStdoutPart2}"
  fi
  assertNoStderr
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_up_Help_prints_use_to_stdout_and_exits_zero()
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
  ${exe} up --help >${stdoutF} 2>${stderrF}
  local exit_status=$?
  assertTrue ${exit_status}
  assertEqualsStdout "${expectedStdout}"
  assertNoStderr
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_up_unknown_prints_msg_to_stderr_and_exits_non_zero()
{
  local expectedStderr="FAILED: unknown argument [salmon]"
  ${exe} up salmon >${stdoutF} 2>${stderrF}
  local exit_status=$?
  assertFalse ${exit_status}
  assertNoStdout
  assertEqualsStderr "${expectedStderr}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_up_unknowns_prints_msg_to_left_of_equal_to_stderr_and_exits_non_zero()
{
  local expectedStderr="FAILED: unknown argument [--spey]
FAILED: unknown argument [--tay]"
  ${exe} up --spey=A --tay=B >${stdoutF} 2>${stderrF}
  local exit_status=$?
  assertFalse ${exit_status}
  assertNoStdout
  assertEqualsStderr "${expectedStderr}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_up_missingLanguages_prints_msg_to_sterr_and_exits_non_zero()
{
  local expectedStderr='FAILED: missing argument value --languages=[???]'
  ${exe} up --languages= >${stdoutF} 2>${stderrF}
  local exit_status=$?
  assertFalse ${exit_status}
  assertNoStdout
  assertEqualsStderr "${expectedStderr}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_up_missingCustom_prints_msg_to_sterr_and_exits_non_zero()
{
  local expectedStderr='FAILED: missing argument value --custom=[???]'
  ${exe} up --custom= >${stdoutF} 2>${stderrF}
  local exit_status=$?
  assertFalse ${exit_status}
  assertNoStdout
  assertEqualsStderr "${expectedStderr}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_up_missingExercises_prints_msg_to_sterr_and_exits_non_zero()
{
  local expectedStderr='FAILED: missing argument value --exercises=[???]'
  ${exe} up --exercises= >${stdoutF} 2>${stderrF}
  local exit_status=$?
  assertFalse ${exit_status}
  assertNoStdout
  assertEqualsStderr "${expectedStderr}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_up_namedLanguagesDoesNotExist_prints_msg_to_sterr_and_exits_non_zero()
{
  local expectedStderr='FAILED: start-point notExist does not exist'
  ${exe} up --exercises=notExist >${stdoutF} 2>${stderrF}
  local exit_status=$?
  assertFalse ${exit_status}
  assertNoStdout
  assertEqualsStderr "${expectedStderr}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_up_namedCustomDoesNotExist_prints_msg_to_sterr_and_exits_non_zero()
{
  local expectedStderr='FAILED: start-point notExist does not exist'
  ${exe} up --custom=notExist >${stdoutF} 2>${stderrF}
  local exit_status=$?
  assertFalse ${exit_status}
  assertNoStdout
  assertEqualsStderr "${expectedStderr}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_up_namedExercisesDoesNotExist_prints_msg_to_sterr_and_exits_non_zero()
{
  local expectedStderr='FAILED: start-point notExist does not exist'
  ${exe} up --exercises=notExist >${stdoutF} 2>${stderrF}
  local exit_status=$?
  assertFalse ${exit_status}
  assertNoStdout
  assertEqualsStderr "${expectedStderr}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_up_namedExercisesIsNotExerciseType_prints_msg_to_sterr_and_exits_non_zero()
{
  local url=https://github.com/cyber-dojo/start-points-custom.git
  ${exe} start-point create jj --git=${url} >${stdoutF} 2>${stderrF}

  local expectedStderr="FAILED: jj is not a exercises start-point (it's type from setup.json is custom)"
  ${exe} up --exercises=jj >${stdoutF} 2>${stderrF}
  local exit_status=$?
  assertFalse ${exit_status}
  assertNoStdout
  assertEqualsStderr "${expectedStderr}"
  ${exe} start-point rm jj
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_up_prints_msg_naming_default_start_points_exits_zero()
{
  ${exe} up >${stdoutF} 2>${stderrF}
  local exit_status=$?
  assertTrue ${exit_status}
  local expectedStdout="Using start-point --languages=languages
Using start-point --exercises=exercises
Using start-point --custom=custom"
  local stdout="`cat ${stdoutF}`"
  if [[ "${stdout}" != *"${expectedStdout}"* ]]; then
    fail "expected stdout to include ${expectedStdout}"
  fi
  assertNoStderr
  ${exe} down >${stdoutF} 2>${stderrF}
  local exit_status=$?
  assertTrue ${exit_status}
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_up_customStartPoint_prints_msg_saying_its_being_used_exits_zero()
{
  local name=jj
  local url="${github_cyber_dojo}/start-points-custom.git"
  ${exe} start-point create ${name} --git=${url} # >${stdoutF} 2>${stderrF}
  local exit_status=$?
  assertTrue ${exit_status}
  ${exe} up --custom=${name} >${stdoutF} 2>${stderrF}
  local exit_status=$?
  assertTrue ${exit_status}

  local expectedStdout="Using start-point --languages=languages
Using start-point --exercises=exercises
Using start-point --custom=${name}"
  local stdout="`cat ${stdoutF}`"
  if [[ "${stdout}" != *"${expectedStdout}"* ]]; then
    fail "expected stdout to include ${expectedStdout}"
  fi
  assertNoStderr
  ${exe} down >${stdoutF} 2>${stderrF}
  local exit_status=$?
  assertTrue ${exit_status}
  ${exe} start-point rm ${name} >${stdoutF} 2>${stderrF}
  local exit_status=$?
  assertTrue ${exit_status}
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

. ./shunit2_helpers.sh
. ./shunit2

