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

test_____no_arg_prints_use()
{
  local -r line1='Use: cyber-dojo update [latest|RELEASE|TAG]'
  local -r line2='Updates image tags ready for the next [cyber-dojo up] command.'
  local -r line3='Example 1: update to latest'
  local -r line4='Example 2: update to a given public release'
  local -r line5='Example 3: update to a given development tag'

  assertUpdate
  assertStdoutIncludes "${line1}"
  assertStdoutIncludes "${line2}"
  assertStdoutIncludes "${line3}"
  assertStdoutIncludes "${line4}"
  assertStdoutIncludes "${line5}"
  assertNoStderr
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

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
  # cyberdojo/versioner:6da7a36 pulls cyberdojo/commander:35f653d
  # but keep that pull out of stdout/stderr assertions
  docker pull cyberdojo/commander:35f653d &> /dev/null

  # This replaces the fake versioner so must be the last test using it.
  assertUpdate 6da7a36

  assertUp

  assertStdoutIncludes 'Using nginx.env=default'
  assertStdoutIncludes 'Using web.env=default'
  #
  assertStdoutIncludes 'Using port=80'
  assertStdoutIncludes "Using custom-start-points=cyberdojo/custom-start-points:ef2352f"
  assertStdoutIncludes 'Using exercises-start-points=cyberdojo/exercises-start-points:c6d6a35'
  assertStdoutIncludes "Using languages-start-points=cyberdojo/languages-start-points:f0eeae4"
  #
  assertStdoutIncludes 'Using commander=cyberdojo/commander:35f653d'
  assertStdoutIncludes 'Using creator=cyberdojo/creator:7a05eb4'
  assertStdoutIncludes 'Using dashboard=cyberdojo/dashboard:0aed98e'
  assertStdoutIncludes 'Using differ=cyberdojo/differ:f05a57c'
  assertStdoutIncludes 'Using nginx=cyberdojo/nginx:7e2c8b4'
  assertStdoutIncludes 'Using repler=cyberdojo/repler:a71729f'
  assertStdoutIncludes 'Using runner=cyberdojo/runner:f1c426f'
  assertStdoutIncludes 'Using saver=cyberdojo/saver:68c5eb7'
  assertStdoutIncludes 'Using shas=cyberdojo/shas:916b024'
  assertStdoutIncludes 'Using web=cyberdojo/web:bbf94ef'
  # assertNoStderr

  assertDown
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

. ${MY_DIR}/shunit2_helpers.sh
. ${MY_DIR}/shunit2
