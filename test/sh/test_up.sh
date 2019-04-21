#!/bin/bash

MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"

. ${MY_DIR}/cyber_dojo_helpers.sh

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_UP() { :; }

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test___success() { :; }

test_____up_prints_start_points_and_port_and_creates_containers()
{
  local readonly custom_name=test_up_custom_1
  assertStartPointCreate ${custom_name}    --custom $(custom_urls)
  local readonly exercises_name=test_up_exercises_1
  assertStartPointCreate ${exercises_name} --exercises $(exercises_urls)
  local readonly languages_name=test_up_languages_1
  assertStartPointCreate ${languages_name} --languages $(languages_urls)
  local readonly port=8462

  assertUp --custom=${custom_name} \
           --exercises=${exercises_name} \
           --languages=${languages_name} \
           --port=${port}

  assertStdoutIncludes 'checking cyberdojofoundation/gcc_assert:latest'
  assertStdoutIncludes 'checking cyberdojofoundation/python_unittest:latest'
  assertStdoutIncludes 'checking cyberdojofoundation/ruby_mini_test:latest'

  assertStdoutIncludes 'checking cyberdojofoundation/csharp_nunit:latest'
  assertStdoutIncludes 'checking cyberdojofoundation/java_junit:latest'
  assertStdoutIncludes 'checking cyberdojofoundation/python_unittest:latest'
  assertStdoutIncludes 'checking cyberdojofoundation/ruby_test_unit:latest'

  assertStdoutIncludes 'Using default grafana.env'
  assertStdoutIncludes 'Using default nginx.env'
  assertStdoutIncludes 'Using default web.env'

  assertStdoutIncludes "Using --custom=${custom_name}"
  assertStdoutIncludes "Using --exercises=${exercises_name}"
  assertStdoutIncludes "Using --languages=${languages_name}"
  assertStdoutIncludes "Using --port=${port}"

  for service in "${service_names[@]}"
  do
    assertStdoutIncludes "Creating cyber-dojo-${service}"
  done
  assertNoStderr

  assertDown
  assertStartPointRm ${custom_name}
  assertStartPointRm ${exercises_name}
  assertStartPointRm ${languages_name}
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____help_arg_prints_use()
{
  local readonly expected_stdout="
Use: cyber-dojo up [OPTIONS]

Creates and starts a cyber-dojo server using named/default start-points.

Options:
  --custom=NAME       Specify the custom start-point name.
  --exercises=NAME    Specify the exercises start-point name.
  --languages=NAME    Specify the languages start-point name.
  --port=PORT         Specify the port number.

Defaults:
  --custom=cyberdojo/custom
  --exercises=cyberdojo/exercises
  --languages=cyberdojo/languages-common
  --port=80

Defaults were created using:
  \$ ./cyber-dojo start-point create \\
      cyberdojo/custom \\
        --custom \\
          https://github.com/cyber-dojo/custom.git

  \$ ./cyber-dojo start-point create \\
      cyberdojo/exercises \\
        --exercises \\
          https://github.com/cyber-dojo/exercises.git

  \$ ./cyber-dojo start-point create \\
      cyberdojo/languages-common \\
        --languages \\
          \$(curl --silent https://github.com/cyber-dojo/languages/master/url_list/common)"

  assertUp --help
  assertStdoutEquals "${expected_stdout}"
  assertNoStderr

  assertUp -h
  assertStdoutEquals "${expected_stdout}"
  assertNoStderr
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test___failure() { :; }

test_____missing_languages()
{
  refuteUp --languages=
  assertNoStdout
  assertStderrEquals 'ERROR: missing argument value --languages=[???]'
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____missing_custom()
{
  refuteUp --custom=
  assertNoStdout
  assertStderrEquals 'ERROR: missing argument value --custom=[???]'
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____missing_exercises()
{
  refuteUp --exercises=
  assertNoStdout
  assertStderrEquals 'ERROR: missing argument value --exercises=[???]'
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____missing_port()
{
  refuteUp --port=
  assertNoStdout
  assertStderrEquals 'ERROR: missing argument value --port=[???]'
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____named_custom_does_not_exist()
{
  local readonly name=notExist
  refuteUp --custom=${name}
  assertNoStdout
  assertStderrEquals "ERROR: cannot find a start-point called ${name}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____named_exercises_does_not_exist()
{
  local readonly name=notExist
  refuteUp --exercises=${name}
  assertNoStdout
  assertStderrEquals "ERROR: cannot find a start-point called ${name}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____named_languages_does_not_exist()
{
  local readonly name=notExist
  refuteUp --languages=${name}
  assertNoStdout
  assertStderrEquals "ERROR: cannot find a start-point called ${name}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____named_exercises_is_not_exercise_type()
{
  local readonly custom_name=test_up_custom_2
  assertStartPointCreate ${custom_name} --custom $(custom_urls)
  refuteUp --exercises=${custom_name}
  assertNoStdout
  assertStderrEquals "ERROR: the type of ${custom_name} is custom (not exercises)"
  assertStartPointRm ${custom_name}
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____unknown_arg()
{
  local readonly name=salmon
  refuteUp ${name}
  assertNoStdout
  assertStderrEquals "ERROR: unknown argument [${name}]"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____unknown_args()
{
  local readonly arg1=--spey
  local readonly arg2=--tay
  refuteUp ${arg1}=A ${arg2}=B
  assertNoStdout
  assertStderrIncludes "ERROR: unknown argument [${arg1}]"
  assertStderrIncludes "ERROR: unknown argument [${arg2}]"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

. ${MY_DIR}/shunit2_helpers.sh
. ${MY_DIR}/shunit2
