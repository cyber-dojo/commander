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

x_test_update_pull_latest_image_for_all_services()
{
  # This test is not turned on.
  # If it runs then the update will [docker pull] the commander
  # image from dockerhub which will overwrite the one created by
  # build.sh and the travis script will repush the old image!
  ${exe} update-images >${stdoutF} 2>${stderrF}
  assertStdoutIncludes "latest: Pulling from cyberdojo/collector"
  assertStdoutIncludes "latest: Pulling from cyberdojo/commander"
  assertStdoutIncludes "latest: Pulling from cyberdojo/differ"
  assertStdoutIncludes "latest: Pulling from cyberdojo/nginx"
  assertStdoutIncludes "latest: Pulling from cyberdojo/runner"
  assertStdoutIncludes "latest: Pulling from cyberdojo/web"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

. ./shunit2_helpers.sh
. ./shunit2
