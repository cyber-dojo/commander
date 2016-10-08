#!/bin/bash

test_start_point_Help_prints_use_to_stdout_and_exits_zero()
{
  local expectedStdout="
Use: cyber-dojo start-point [COMMAND]

Manage cyber-dojo start-points

Commands:
  create         Creates a new start-point
  rm             Removes a start-point
  ls             Lists the names of all start-points
  inspect        Displays details of a start-point
  pull           Pulls all the docker images named inside a start-point

Run 'cyber-dojo start-point COMMAND help' for more information on a command"
  ./cyber-dojo start-point >${stdoutF} 2>${stderrF}
  local exit_status=$?
  assertTrue ${exit_status}
  assertEqualsStdout "${expectedStdout}"
  assertNoStderr
  ./cyber-dojo start-point help >${stdoutF} 2>${stderrF}
  local exit_status=$?
  assertTrue ${exit_status}
  assertEqualsStdout "${expectedStdout}"
  assertNoStderr
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_start_point_Unknown_prints_terse_msg_to_stderr_and_exits_non_zero()
{
  local expectedStderr="FAILED: unknown argument [unknown]"
  ./cyber-dojo start-point unknown >${stdoutF} 2>${stderrF}
  local exit_status=$?
  assertFalse ${exit_status}
  assertNoStdout
  assertEqualsStderr "${expectedStderr}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# create
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_start_point_create_Help_prints_use_to_stdout_and_exits_zero()
{
  local expectedStdout="
Use: cyber-dojo start-point create NAME --git=URL
Creates a start-point named NAME from a git clone of URL

Use: cyber-dojo start-point create NAME --dir=DIR
Creates a start-point named NAME from a copy of DIR

NAME's first letter must be [a-zA-Z0-9]
NAME's remaining letters must be [a-zA-Z0-9_.-]
NAME must be at least two letters long"
  ./cyber-dojo start-point create >${stdoutF} 2>${stderrF}
  local exit_status=$?
  assertTrue ${exit_status}
  assertEqualsStdout "${expectedStdout}"
  assertNoStderr
  ./cyber-dojo start-point create help >${stdoutF} 2>${stderrF}
  local exit_status=$?
  assertTrue ${exit_status}
  assertEqualsStdout "${expectedStdout}"
  assertNoStderr
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_start_point_create_IllegalName_first_letter_prints_terse_msg_to_stderr_and_exits_non_zero()
{
  local expectedStderr="FAILED: +bad is an illegal NAME"
  ./cyber-dojo start-point create +bad >${stdoutF} 2>${stderrF}
  local exit_status=$?
  assertFalse ${exit_status}
  assertNoStdout
  assertEqualsStderr "${expectedStderr}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_start_point_create_IllegalName_second_letter_prints_terse_msg_to_stderr_and_exits_non_zero()
{
  local expectedStderr="FAILED: b+ad is an illegal NAME"
  ./cyber-dojo start-point create b+ad >${stdoutF} 2>${stderrF}
  local exit_status=$?
  assertFalse ${exit_status}
  assertNoStdout
  assertEqualsStderr "${expectedStderr}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_start_point_create_IllegalName_one_letter_name_prints_terse_msg_to_stderr_and_exits_non_zero()
{
  local expectedStderr="FAILED: b is an illegal NAME"
  ./cyber-dojo start-point create b >${stdoutF} 2>${stderrF}
  local exit_status=$?
  assertFalse ${exit_status}
  assertNoStdout
  assertEqualsStderr "${expectedStderr}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_start_point_create_name_UnknownArg_prints_terse_msg_to_stderr_and_exits_non_zero()
{
  local expectedStderr="FAILED: unknown argument [--where]"
  local name=jj
  ./cyber-dojo start-point create ${name} --where=tay >${stdoutF} 2>${stderrF}
  local exit_status=$?
  assertFalse ${exit_status}
  assertNoStdout
  assertEqualsStderr "${expectedStderr}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_start_point_create_name_UnknownArgs_prints_terse_msg_to_stderr_and_exits_non_zero()
{
  local expectedStderr="FAILED: unknown argument [--where]
FAILED: unknown argument [--there]"
  local name=jj
  ./cyber-dojo start-point create ${name} --where=tay --there=x >${stdoutF} 2>${stderrF}
  local exit_status=$?
  assertFalse ${exit_status}
  assertNoStdout
  assertEqualsStderr "${expectedStderr}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_start_point_create_name_DirAndGit_args_prints_terse_msg_to_stderr_and_exits_non_zero()
{
  local expectedStderr="FAILED: specify --git=... OR --dir=... but not both"
  local name=jj
  ./cyber-dojo start-point create ${name} --dir=where --git=url >${stdoutF} 2>${stderrF}
  local exit_status=$?
  assertFalse ${exit_status}
  assertNoStdout
  assertEqualsStderr "${expectedStderr}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

github_cyber_dojo='https://github.com/cyber-dojo'

test_start_point_create_NameExists_prints_terse_msg_to_stderr_and_exits_non_zero()
{
  local name=jj
  local url="${github_cyber_dojo}/start-points-exercises.git"
  ./cyber-dojo start-point create ${name} --git=${url} >${stdoutF} 2>${stderrF}
  local exit_status=$?
  assertTrue ${exit_status}
  assertNoStdout
  assertNoStderr

  local expectedStderr="FAILED: a start-point called ${name} already exists"
  ./cyber-dojo start-point create ${name} --git=${url} >${stdoutF} 2>${stderrF}
  local exit_status=$?
  assertFalse ${exit_status}
  assertNoStdout
  assertEqualsStderr "${expectedStderr}"

  ./cyber-dojo start-point rm ${name}
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

. ./test_helpers.sh
. ./shunit2
