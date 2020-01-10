#!/bin/bash

MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"
. ${MY_DIR}/cyber_dojo_helpers.sh

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_UPDATE() { :; }

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Run failure cases first. Tests that do an actual update need to be last
# as they replace the fake versioner with a real one.

test___failure() { :; }

test_____unknown_tag_prints_to_stderr()
{
  local -r arg=salmon
  refuteUpdate ${arg}
  assertNoStdout
  assertStderrIncludes "Error response from daemon: manifest for cyberdojo/versioner:${arg} not found"
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

test___success() { :; }

test_____help_arg_prints_use()
{
  local -r line1='Use: cyber-dojo update [latest|RELEASE|TAG]'
  local -r line2='Updates image tags ready for the next [cyber-dojo up] command.'
  local -r line3='Example 1: update to latest'
  local -r line4='Example 2: update to a given public release'
  local -r line5='Example 3: update to a given development tag'

  assertUpdate --help
  assertStdoutIncludes "${line1}"
  assertStdoutIncludes "${line2}"
  assertStdoutIncludes "${line3}"
  assertStdoutIncludes "${line4}"
  assertStdoutIncludes "${line5}"
  assertNoStderr

  assertUpdate -h
  assertStdoutIncludes "${line1}"
  assertStdoutIncludes "${line2}"
  assertStdoutIncludes "${line3}"
  assertStdoutIncludes "${line4}"
  assertStdoutIncludes "${line5}"
  assertNoStderr
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____updating_to_specific_version_causes_next_up_to_use_service_tags_embedded_in_that_version()
{
  local -r custom_name=test_up_custom_246
  assertStartPointCreate ${custom_name}    --custom $(custom_urls)
  local -r languages_name=test_up_languages_246
  assertStartPointCreate ${languages_name} --languages $(languages_urls)

  # cyberdojo/versioner:5e3bc0b pulls cyberdojo/commander:b291513
  # but keep that pull out of stdout/stderr assertions
  docker pull cyberdojo/commander:b291513 &> /dev/null

  # This replaces the fake versioner so must be the last test using it.
  assertUpdate 5e3bc0b
  # use languages-small to minimize language-test-framework pulls
  assertUp --languages=${languages_name} --custom=${custom_name}

  assertStdoutIncludes 'Using nginx.env=default'
  assertStdoutIncludes 'Using web.env=default'
  #
  assertStdoutIncludes 'Using port=80'
  assertStdoutIncludes "Using custom=${custom__name}"
  assertStdoutIncludes 'Using exercises=cyberdojo/exercises:16fb5d9'
  assertStdoutIncludes "Using languages=${languages_name}"
  #
  assertStdoutIncludes 'Using differ=cyberdojo/differ:5c95484'
  assertStdoutIncludes 'Using mapper=cyberdojo/mapper:5729d56'
  assertStdoutIncludes 'Using nginx=cyberdojo/nginx:380c557'
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

. ${MY_DIR}/shunit2_helpers.sh
. ${MY_DIR}/shunit2
