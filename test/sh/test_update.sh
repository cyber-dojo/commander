#!/bin/bash
set -e

MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"

. ${MY_DIR}/cyber_dojo_helpers.sh

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_UPDATE() { :; }

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test___success() { :; }

test_____help_arg_prints_use()
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

test_____updating_to_specific_tag_causes_next_up_to_use_specific_service_tags()
{
  assertUpdate 8fdf595
  assertStdoutIncludes "8fdf595: Pulling from cyberdojo/versioner"
  # use languages-small to minimize language-test-framework pulls
  assertUp --languages=cyberdojo/languages-small:8ab7cd9
  assertStdoutIncludes 'Using custom=cyberdojo/custom:a089497'
  assertStdoutIncludes 'Using exercises=cyberdojo/exercises:16fb5d9'
  assertStdoutIncludes 'Using languages=cyberdojo/languages-small:8ab7cd9'
  assertStdoutIncludes 'Using differ=cyberdojo/differ:5c95484'
  assertStdoutIncludes 'Using grafana=cyberdojo/grafana:449370c'
  assertStdoutIncludes 'Using mapper=cyberdojo/mapper:5729d56'
  assertStdoutIncludes 'Using nginx=cyberdojo/nginx:380c557'
  assertStdoutIncludes 'Using prometheus=cyberdojo/prometheus:f0f7978'
  assertStdoutIncludes 'Using ragger=cyberdojo/ragger:5998a76'
  assertStdoutIncludes 'Using runner=cyberdojo/runner:1b06f00'
  assertStdoutIncludes 'Using saver=cyberdojo/saver:8485ef3'
  assertStdoutIncludes 'Using web=cyberdojo/web:5121b0b'
  assertStdoutIncludes 'Using zipper=cyberdojo/zipper:2047f30'
  assertNoStderr

  assertDown
  assertUpdate latest # reset back
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test___failure() { :; }

test_____unknown_tag_prints_to_stderr()
{
  local readonly arg=salmon
  refuteUpdate ${arg}
  assertNoStdout
  assertStderrEquals "Error response from daemon: manifest for cyberdojo/versioner:${arg} not found"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

OFF_test_____too_many_args()
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
