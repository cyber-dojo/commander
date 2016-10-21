#!/bin/bash

. ./cyber_dojo_helpers.sh

test_update_help_prints_use_to_stdout_and_exits_zero()
{
  local expected_stdout="
Use: cyber-dojo update

Updates all cyber-dojo docker images and the cyber-dojo script file"
  ${exe} update --help >${stdoutF} 2>${stderrF}
  assertTrue $?
  assertEqualsStdout "${expected_stdout}"
  assertNoStderr
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_update_unknown_prints_msg_to_stderr_and_exits_non_zero()
{
  local expected_stderr="FAILED: unknown argument [unknown]"
  ${exe} update unknown >${stdoutF} 2>${stderrF}
  assertFalse $?
  assertNoStdout
  assertEqualsStderr "${expected_stderr}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_update_images_prints_msg_to_stderr_and_exits_non_zero()
{
  # update-images is only callable indirectly via
  # ./cyber-dojo update
  # after the command line arguments have been checked
  local expected_stderr="FAILED: unknown argument [update-images]"
  ${exe} update-images >${stdoutF} 2>${stderrF}
  assertFalse $?
  assertNoStdout
  assertEqualsStderr "${expected_stderr}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

x_test_update()
{
  # this could be a long running test...
  # Stdout? Stderr? to check
  local expected_1="Stopping cyber-dojo-nginx ... done
Stopping cyber-dojo-web ... done
Stopping cyber-dojo-differ ... done"

  local expected_2="Removing cyber-dojo-nginx ... done
Removing cyber-dojo-web ... done
Removing cyber-dojo-differ ... done"

  local expected_3="1.12.2: Pulling from cyberdojo/commander"
  local expected_4="latest: Pulling from cyberdojo/nginx"
  local expected_5="1.12.2: Pulling from cyberdojo/web"
  local expected_6="latest: Pulling from cyberdojo/differ"

  local expected_7="Using start-point --languages=languages
Using start-point --exercises=exercises
Using start-point --custom=custom"
  local expected_8="Creating cyber-dojo-differ
Creating cyber-dojo-web
Creating cyber-dojo-nginx"

  #...

}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

. ./shunit2_helpers.sh
. ./shunit2
