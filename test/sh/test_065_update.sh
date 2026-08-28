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
  # Daemons word this differently: some say "manifest for X not found", others
  # say 'failed to resolve reference "X": X: not found'. What both carry, and
  # what this pins, is that the daemon refused the tag and named it.
  assertStderrIncludes \
    'Error response from daemon:' \
    "cyberdojo/versioner:${arg}" \
    'not found'
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____too_old_version_is_refused_and_leaves_current_version_in_place()
{
  local -r arg=0.0.2
  refuteUpdate ${arg}
  assertNoStdout
  assertStderrIncludes \
    "${arg}" \
    "$(oldest_runnable_release)"
  # The refusal must not have switched anything.
  assertVersion
  refuteStdoutIncludes "Version: ${arg}"
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

test_____updating_to_specific_version_causes_next_up_to_use_image_tags_embedded_in_that_version()
{
  # The oldest runnable release pulls cyberdojo/commander:7dd09ac
  # but keep that pull out of stdout/stderr assertions
  docker pull cyberdojo/commander:7dd09ac &> /dev/null

  # This replaces the fake versioner so must be the last test using it.
  assertUpdate "$(oldest_runnable_release)"

  assertUp

  assertStdoutIncludes 'Using nginx.env=default'
  assertStdoutIncludes 'Using web.env=default'
  #
  assertStdoutIncludes 'Using port=80'
  assertStdoutIncludes 'Using custom-start-points=cyberdojo/custom-start-points:22c7a00'
  assertStdoutIncludes 'Using exercises-start-points=cyberdojo/exercises-start-points:901efbe'
  assertStdoutIncludes 'Using languages-start-points=cyberdojo/languages-start-points:becc571'
  #
  assertStdoutIncludes 'Using commander=cyberdojo/commander:7dd09ac'
  assertStdoutIncludes 'Using creator=cyberdojo/creator:b50aee6'
  assertStdoutIncludes 'Using dashboard=cyberdojo/dashboard:b9b11ef'
  assertStdoutIncludes 'Using differ=cyberdojo/differ:f672103'
  assertStdoutIncludes 'Using nginx=cyberdojo/nginx:5fcea19'
  assertStdoutIncludes 'Using repler=cyberdojo/repler:a7deefa'
  assertStdoutIncludes 'Using runner=cyberdojo/runner:e79210a'
  assertStdoutIncludes 'Using saver=cyberdojo/saver:68c5eb7'
  assertStdoutIncludes 'Using shas=cyberdojo/shas:48fac38'
  assertStdoutIncludes 'Using web=cyberdojo/web:d3dd6ab'
  # assertNoStderr

  assertDown
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

. ${MY_DIR}/shunit2_helpers.sh
. ${MY_DIR}/shunit2
