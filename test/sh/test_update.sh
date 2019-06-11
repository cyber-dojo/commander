#!/bin/bash

MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"
. ${MY_DIR}/cyber_dojo_helpers.sh

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_UPDATE() { :; }

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test___success() { :; }

test_____help_arg_prints_use()
{
  local -r expected_stdout="
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

test_____updating_to_specific_version_causes_next_up_to_use_service_tags_embedded_in_that_version()
{
  local -r custom_name=test_up_custom_246
  assertStartPointCreate ${custom_name}    --custom $(custom_urls)
  local -r languages_name=test_up_languages_246
  assertStartPointCreate ${languages_name} --languages $(languages_urls)

  # don't use cyberdojo/commander:latest
  unset COMMANDER_TAG
  # cyberdojo/versioner:5e3bc0b pulls cyberdojo/commander:b291513
  # but keep that pull out of stdout/stderr assertions
  docker pull cyberdojo/commander:b291513

  assertUpdate 5e3bc0b
  # use languages-small to minimize language-test-framework pulls
  assertUp --languages=${languages_name} --custom=${custom_name}
  export COMMANDER_TAG=latest

  assertStdoutIncludes 'Using grafana.env=default'
  assertStdoutIncludes 'Using nginx.env=default'
  assertStdoutIncludes 'Using web.env=default'
  #
  assertStdoutIncludes 'Using port=80'
  assertStdoutIncludes "Using custom=${custom__name}"
  assertStdoutIncludes 'Using exercises=cyberdojo/exercises:16fb5d9'
  assertStdoutIncludes "Using languages=${languages_name}"
  #
  assertStdoutIncludes 'Using differ=cyberdojo/differ:5c95484'
  assertStdoutIncludes 'Using grafana=cyberdojo/grafana:449370c'
  assertStdoutIncludes 'Using mapper=cyberdojo/mapper:5729d56'
  assertStdoutIncludes 'Using nginx=cyberdojo/nginx:380c557'
  assertStdoutIncludes 'Using prometheus=cyberdojo/prometheus:f0f7978'
  assertStdoutIncludes 'Using ragger=cyberdojo/ragger:5998a76'
  assertStdoutIncludes 'Using runner=cyberdojo/runner:1b06f00'
  assertStdoutIncludes 'Using saver=cyberdojo/saver:8485ef3'
  assertStdoutIncludes 'Using web=cyberdojo/web:c66c2da'
  assertStdoutIncludes 'Using zipper=cyberdojo/zipper:2047f30'
  assertNoStderr

  assertDown
  assertStartPointRm ${custom_name}
  assertStartPointRm ${languages_name}
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test___failure() { :; }

test_____unknown_tag_prints_to_stderr()
{
  local -r arg=salmon
  refuteUpdate ${arg}
  assertNoStdout
  assertStderrEquals "Error response from daemon: manifest for cyberdojo/versioner:${arg} not found"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____too_many_args_prints_to_stderr()
{
  local -r arg1=salmon
  local -r arg2=parr
  refuteUpdate ${arg1} ${arg2}
  assertNoStdout
  assertStderrIncludes "ERROR: too many arguments [${arg1} ${arg2}]"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

. ${MY_DIR}/shunit2_helpers.sh
. ${MY_DIR}/shunit2
