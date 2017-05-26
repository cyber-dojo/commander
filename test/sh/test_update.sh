#!/bin/bash

. ./cyber_dojo_helpers.sh

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_UPDATE() { :; }

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test___SUCCESS_exits_zero() { :; }

test_____help_arg_prints_use_to_stdout()
{
  local expected_stdout="
Use: cyber-dojo update [OPTIONS]

Updates all cyber-dojo server and language images and the cyber-dojo script file

  server      update the server images and the cyber-dojo script file
              but not the current languages

  languages   update the current languages but not the
              server images or the cyber-dojo script file"

  assertUpdate --help
  assertStdoutEquals "${expected_stdout}"
  assertNoStderr
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

x_test_____pull_latest_images_for_all_services()
{
  # This test is turned off.
  # If it runs then the update will [docker pull] the commander
  # image from dockerhub which will overwrite the one created by
  # build.sh and the travis script will repush the old image!
  ${exe} update >${stdoutF} 2>${stderrF}
  assertStdoutIncludes 'latest: Pulling from cyberdojo/collector'
  assertStdoutIncludes 'latest: Pulling from cyberdojo/commander'
  assertStdoutIncludes 'latest: Pulling from cyberdojo/differ'
  assertStdoutIncludes 'latest: Pulling from cyberdojo/grafana'
  assertStdoutIncludes 'latest: Pulling from cyberdojo/nginx'
  assertStdoutIncludes 'latest: Pulling from cyberdojo/prometheus'
  assertStdoutIncludes 'latest: Pulling from cyberdojo/runner'
  assertStdoutIncludes 'latest: Pulling from cyberdojo/runner-stateless'
  assertStdoutIncludes 'latest: Pulling from cyberdojo/storer'
  assertStdoutIncludes 'latest: Pulling from cyberdojo/web'
  assertNoStderr
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

x_test_____pull_latest_images_for_all_languages()
{
  ${exe} update languages >${stdoutF} 2>${stderrF}
  assertFalse $?
  assertStdoutIncludes 'latest: Pulling from cyberdojofoundation/gcc_assert'
  assertNoStderr
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test___FAILURE_prints_msg_to_stderr_and_exits_non_zero() { :; }

test_____unknown_arg()
{
  local arg=salmon
  refuteUpdate ${arg}
  assertNoStdout
  assertStderrEquals "FAILED: unknown argument [${arg}]"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____unknown_args()
{
  local arg1=salmon
  local arg2=parr
  refuteUpdate ${arg1} ${arg2}
  assertNoStdout
  assertStderrIncludes "FAILED: unknown argument [${arg1}]"
  assertStderrIncludes "FAILED: unknown argument [${arg2}]"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

. ./shunit2_helpers.sh
. ./shunit2
