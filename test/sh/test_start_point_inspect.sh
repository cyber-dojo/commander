#!/bin/bash

MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"
. ${MY_DIR}/cyber_dojo_helpers.sh

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_START_POINT_INSPECT() { :; }

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test___success() { :; }

test_____no_args_or_help_prints_use()
{
  local -r expected_stdout="
Use: cyber-dojo start-point inspect NAME

Prints, in JSON form, the display_name, image_name, sha, and url of each entry in the named start-point"
  assertStartPointInspect
  assertStdoutEquals "${expected_stdout}"
  assertNoStderr

  assertStartPointInspect --help
  assertStdoutEquals "${expected_stdout}"
  assertNoStderr
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____custom_start_point_prints_details()
{
  local -r name=ok1
  assertStartPointCreate ${name} --custom $(custom_urls)
  assertStartPointInspect ${name}
  assertStdoutIncludes '{'
  assertStdoutIncludes '  "Java, JUnit": {'
  assertStdoutIncludes '    "url":'
  assertStdoutIncludes '    "sha":'
  assertStdoutIncludes '    "image_name": "cyberdojofoundation/java_junit"'
  assertStdoutIncludes '  }'
  assertStdoutIncludes '}'
  assertNoStderr
  assertStartPointRm ${name}
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____exercises_start_point_prints_details()
{
  local -r name=ok2
  assertStartPointCreate ${name} --exercises $(exercises_urls)
  assertStartPointInspect ${name}
  assertStdoutIncludes '{'
  assertStdoutIncludes '  "Print Diamond": {'
  assertStdoutIncludes '    "url":'
  assertStdoutIncludes '    "sha":'
  refuteStdoutIncludes '    "image_name":'
  assertStdoutIncludes '  }'
  assertStdoutIncludes '}'
  assertNoStderr
  assertStartPointRm ${name}
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____languages_start_point_prints_details()
{
  local -r name=ok3
  assertStartPointCreate ${name} --languages $(languages_urls)
  assertStartPointInspect ${name}
  assertStdoutIncludes '{'
  assertStdoutIncludes '  "Ruby, MiniTest": {'
  assertStdoutIncludes '    "url":'
  assertStdoutIncludes '    "sha":'
  assertStdoutIncludes '    "image_name": "cyberdojofoundation/ruby_mini_test"'
  assertStdoutIncludes '  }'
  assertStdoutIncludes '}'
  assertNoStderr
  assertStartPointRm ${name}
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test___failure() { :; }

test_____absent_start_point()
{
  local -r name=absent
  refuteStartPointInspect ${name}
  assertNoStdout
  assertStderrEquals "ERROR: ${name} does not exist."
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____present_but_not_a_start_point()
{
  local -r name=cyberdojo/start-points-base
  refuteStartPointInspect ${name}
  assertNoStdout
  assertStderrEquals "ERROR: ${name} is not a cyber-dojo start-point image."
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____unknown_arg()
{
  local -r name=ok4
  local -r arg=wibble
  assertStartPointCreate ${name} --custom $(custom_urls)
  refuteStartPointInspect ${name} ${arg}
  assertNoStdout
  assertStderrEquals "ERROR: unknown argument [${arg}]"
  assertStartPointRm ${name}
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____unknown_args()
{
  local -r name=ok5
  local -r arg1=springer
  local -r arg2=salmon
  assertStartPointCreate ${name} --custom $(custom_urls)
  refuteStartPointInspect ${name} ${arg1} ${arg2}
  assertNoStdout
  assertStderrIncludes "ERROR: unknown argument [${arg1}]"
  assertStderrIncludes "ERROR: unknown argument [${arg2}]"
  assertStartPointRm ${name}
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

. ${MY_DIR}/shunit2_helpers.sh
. ${MY_DIR}/shunit2
