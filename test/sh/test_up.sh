#!/bin/bash

MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"

. ${MY_DIR}/cyber_dojo_helpers.sh

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_UP() { :; }

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test___success() { :; }

test_____small_prints_two_start_points_and_port_and_creates_containers()
{
  local readonly port=8462
  local readonly name=small
  local readonly url=`absPath ${MY_DIR}/../rb/example_start_points/languages_list_small`
  assertStartPointCreate ${name} --list=${url}

  assertUp --languages=small --port=${port}

  #assertStdoutIncludes "checking images in [${name}] all exist..."
  assertStdoutIncludes 'checking cyberdojofoundation/gcc_assert:latest'
  assertStdoutIncludes 'checking cyberdojofoundation/python_unittest:latest'

  #assertStdoutIncludes 'checking images in [custom] all exist...'
  assertStdoutIncludes 'checking cyberdojofoundation/csharp_nunit:latest'
  assertStdoutIncludes 'checking cyberdojofoundation/gpp_assert:latest'
  assertStdoutIncludes 'checking cyberdojofoundation/java_junit:latest'
  assertStdoutIncludes 'checking cyberdojofoundation/python_unittest:latest'
  assertStdoutIncludes 'checking cyberdojofoundation/ruby_test_unit:latest'

  assertStdoutIncludes 'Using default grafana.env'
  assertStdoutIncludes 'Using default nginx.env'
  assertStdoutIncludes 'Using default web.env'
  assertStdoutIncludes 'Using default zipper.env'

  assertStdoutIncludes "Using --languages=${name}"
  assertStdoutIncludes 'Using --exercises=exercises'
  assertStdoutIncludes 'Using --custom=custom'
  assertStdoutIncludes "Using --port=${port}"

  assertStdoutIncludes 'Creating cyber-dojo-differ'
  assertStdoutIncludes 'Creating cyber-dojo-grafana'
  assertStdoutIncludes 'Creating cyber-dojo-prometheus'
  assertStdoutIncludes 'Creating cyber-dojo-nginx'
  assertStdoutIncludes 'Creating cyber-dojo-runner'
  assertStdoutIncludes 'Creating cyber-dojo-starter'
  assertStdoutIncludes 'Creating cyber-dojo-storer'
  assertStdoutIncludes 'Creating cyber-dojo-web'
  assertStdoutIncludes 'Creating cyber-dojo-zipper'
  assertStdoutIncludes 'Creating cyber-dojo-saver'
  assertStdoutIncludes 'Creating cyber-dojo-porter'
  assertNoStderr
  assertDown
  assertStartPointRm ${name}
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____help_arg_prints_use()
{
  local readonly expected_stdout="
Use: cyber-dojo up [OPTIONS]

Creates and starts the cyber-dojo server using named/default start-points

  --languages=START-POINTS  Specify the languages start-points.
                            Defaults to the start-points named 'languages' created from
                            https://github.com/cyber-dojo/start-points-languages.git

  --exercises=START-POINTS  Specify the exercises start-points.
                            Defaults to the start-points named 'exercises' created from
                            https://github.com/cyber-dojo/start-points-exercises.git

  --custom=START-POINTS     Specify the custom start-points.
                            Defaults to the start-points named 'custom' created from
                            https://github.com/cyber-dojo/start-points-custom.git

  --port=LISTEN-PORT        Specify port to listen on.
                            Defaults to 80"

  assertUp --help
  assertStdoutEquals "${expected_stdout}"
  assertNoStderr
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test___failure() { :; }

test_____missing_languages()
{
  refuteUp --languages=
  assertNoStdout
  assertStderrEquals 'FAILED: missing argument value --languages=[???]'
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____missing_custom()
{
  refuteUp --custom=
  assertNoStdout
  assertStderrEquals 'FAILED: missing argument value --custom=[???]'
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____missing_exercises()
{
  refuteUp --exercises=
  assertNoStdout
  assertStderrEquals 'FAILED: missing argument value --exercises=[???]'
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____missing_port()
{
  refuteUp --port=
  assertNoStdout
  assertStderrEquals 'FAILED: missing argument value --port=[???]'
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____named_languages_does_not_exist()
{
  local readonly name=notExist
  refuteUp --languages=${name}
  assertNoStdout
  assertStderrEquals "FAILED: start-point ${name} does not exist"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____named_custom_does_not_exist()
{
  local readonly name=notExist
  refuteUp --custom=${name}
  assertNoStdout
  assertStderrEquals "FAILED: start-point ${name} does not exist"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____named_exercises_does_not_exist()
{
  local readonly name=notExist
  refuteUp --exercises=${name}
  assertNoStdout
  assertStderrEquals "FAILED: start-point ${name} does not exist"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____named_exercises_is_not_exercise_type()
{
  local readonly name=jj
  local url=https://github.com/cyber-dojo/start-points-custom.git
  assertStartPointCreate ${name} --git=${url}
  refuteUp --exercises=${name}
  assertNoStdout
  assertStderrEquals "FAILED: ${name} is not a exercises start-point (it's type from setup.json is custom)"
  assertStartPointRm ${name}
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____unknown_arg()
{
  local readonly name=salmon
  refuteUp ${name}
  assertNoStdout
  assertStderrEquals "FAILED: unknown argument [${name}]"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____unknown_args()
{
  local readonly arg1=--spey
  local readonly arg2=--tay
  refuteUp ${arg1}=A ${arg2}=B
  assertNoStdout
  assertStderrIncludes "FAILED: unknown argument [${arg1}]"
  assertStderrIncludes "FAILED: unknown argument [${arg2}]"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

. ${MY_DIR}/shunit2_helpers.sh
. ${MY_DIR}/shunit2
