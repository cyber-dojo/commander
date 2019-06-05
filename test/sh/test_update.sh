#!/bin/bash

MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"

. ${MY_DIR}/cyber_dojo_helpers.sh

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_UPDATE() { :; }

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test___success() { :; }

OFF_test_____help_arg_prints_use()
{
  local readonly expected_stdout="
Use: cyber-dojo update [latest|TAG]

Updates all cyber-dojo server images and the cyber-dojo script file"

  assertUpdate --help
  assertStdoutEquals "${expected_stdout}"
  assertNoStderr

  assertUpdate -h
  assertStdoutEquals "${expected_stdout}"
  assertNoStderr
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

OFF_test_____pull_latest_images_for_all_services()
{
  # This test is turned off.
  # If it runs then the update will [docker pull] the commander
  # image from dockerhub which will overwrite the one created by
  # build.sh and the travis script will repush the old image!
  # Proper [update] semantics is WIP
  assertUpdate
  assertStdoutIncludes 'latest: Pulling from cyberdojo/commander'
  assertStdoutIncludes 'latest: Pulling from cyberdojo/differ'
  assertStdoutIncludes 'latest: Pulling from cyberdojo/grafana'
  assertStdoutIncludes 'latest: Pulling from cyberdojo/mapper'
  assertStdoutIncludes 'latest: Pulling from cyberdojo/nginx'
  assertStdoutIncludes 'latest: Pulling from cyberdojo/prometheus'
  assertStdoutIncludes 'latest: Pulling from cyberdojo/runner'
  assertStdoutIncludes 'latest: Pulling from cyberdojo/saver'
  assertStdoutIncludes 'latest: Pulling from cyberdojo/web'
  assertStdoutIncludes 'latest: Pulling from cyberdojo/zipper'
  assertNoStderr
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test___failure() { :; }

OFF_test_____unknown_arg()
{
  local readonly arg=salmon
  refuteUpdate ${arg}
  assertNoStdout
  assertStderrEquals "ERROR: unknown argument [${arg}]"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

OFF_test_____unknown_args()
{
  local readonly arg1=salmon
  local readonly arg2=parr
  refuteUpdate ${arg1} ${arg2}
  assertNoStdout
  assertStderrIncludes "ERROR: unknown argument [${arg1}]"
  assertStderrIncludes "ERROR: unknown argument [${arg2}]"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

. ${MY_DIR}/shunit2_helpers.sh
. ${MY_DIR}/shunit2
