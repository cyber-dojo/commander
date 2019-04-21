#!/bin/bash

MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"

. ${MY_DIR}/cyber_dojo_helpers.sh

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_UP() { :; }

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test___success() { :; }

test_____up_prints_start_points_and_port_and_creates_containers()
{
  local readonly port=8462
  local readonly languages_name=small
  assertStartPointCreate ${languages_name} --languages $(languages_urls)
  assertUp --languages=${languages_name} --port=${port}

  #assertStdoutIncludes "checking images in [${name}] all exist..."
  assertStdoutIncludes 'checking cyberdojofoundation/gcc_assert:latest'
  assertStdoutIncludes 'checking cyberdojofoundation/python_unittest:latest'
  assertStdoutIncludes 'checking cyberdojofoundation/ruby_mini_test:latest'

  #assertStdoutIncludes 'checking images in [custom] all exist...'
  #assertStdoutIncludes 'checking cyberdojofoundation/csharp_nunit:latest'
  #assertStdoutIncludes 'checking cyberdojofoundation/gpp_assert:latest'
  #assertStdoutIncludes 'checking cyberdojofoundation/java_junit:latest'
  #assertStdoutIncludes 'checking cyberdojofoundation/python_unittest:latest'
  #assertStdoutIncludes 'checking cyberdojofoundation/ruby_test_unit:latest'

  assertStdoutIncludes 'Using default grafana.env'
  assertStdoutIncludes 'Using default nginx.env'
  assertStdoutIncludes 'Using default web.env'
  #assertStdoutIncludes 'Using default zipper.env'

  assertStdoutIncludes 'Using --custom=cyberdojo/custom:latest'
  assertStdoutIncludes 'Using --exercises=cyberdojo/exercises:latest'
  assertStdoutIncludes "Using --languages=${languages_name}"
  assertStdoutIncludes "Using --port=${port}"

  assertStdoutIncludes 'Creating cyber-dojo-differ'
  assertStdoutIncludes 'Creating cyber-dojo-grafana'
  assertStdoutIncludes 'Creating cyber-dojo-prometheus'
  assertStdoutIncludes 'Creating cyber-dojo-nginx'
  assertStdoutIncludes 'Creating cyber-dojo-runner'
  assertStdoutIncludes 'Creating cyber-dojo-languages'
  assertStdoutIncludes 'Creating cyber-dojo-exercises'
  assertStdoutIncludes 'Creating cyber-dojo-custom'
  assertStdoutIncludes 'Creating cyber-dojo-web'
  assertStdoutIncludes 'Creating cyber-dojo-zipper'
  assertStdoutIncludes 'Creating cyber-dojo-saver'
  assertStdoutIncludes 'Creating cyber-dojo-mapper'
  assertNoStderr

  assertDown
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

XXX_test_____named_exercises_is_not_exercise_type()
{
  local readonly name=jj
  local url=https://github.com/cyber-dojo/start-points-custom.git
  assertStartPointCreate ${name} --git=${url}
  refuteUp --exercises=${name}
  assertNoStdout
  assertStderrEquals "ERROR: ${name} is not a exercises start-point (it's type from setup.json is custom)"
  assertStartPointRm ${name}
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
