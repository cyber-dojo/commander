#!/bin/bash

MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"
. ${MY_DIR}/cyber_dojo_helpers.sh

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_UP() { :; }

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test___success() { :; }

test_____up_prints_start_points_and_port_and_creates_containers()
{
  assertUpdate latest
  local -r custom_name=test_up_custom_1
  assertStartPointCreate ${custom_name}    --custom $(custom_urls)
  local -r exercises_name=test_up_exercises_1
  assertStartPointCreate ${exercises_name} --exercises $(exercises_urls)
  local -r languages_name=test_up_languages_1
  assertStartPointCreate ${languages_name} --languages $(languages_urls)
  local -r port=8462

  assertUp --custom=${custom_name} \
           --exercises=${exercises_name} \
           --languages=${languages_name} \
           --port=${port}

  assertStdoutIncludes 'Using nginx.env=default'
  assertStdoutIncludes 'Using web.env=default'
  assertStdoutIncludes "Using port=${port}"
  assertStdoutIncludes "Using custom=${custom_name}"
  assertStdoutIncludes "Using exercises=${exercises_name}"
  assertStdoutIncludes "Using languages=${languages_name}"
  for service in "${service_names[@]}"
  do
    assertStdoutIncludes "Using ${service}=cyberdojo/${service}:"
  done

  for service in custom exercises languages "${service_names[@]}"
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
  local -r expected_stdout="
Use: cyber-dojo up [OPTIONS]

Creates and starts a cyber-dojo server using default/named port,
and start-points unless overridden with command-line options.

Command-line-arg           Default
--port=NUMBER              80
--custom=IMAGE_NAME        cyberdojo/custom-start-points
--exercises=IMAGE_NAME     cyberdojo/exercises-start-points
--languages=IMAGE_NAME     cyberdojo/languages-start-points-common

The default start-point images were created using:

  cyber-dojo start-point create \\
    cyberdojo/custom-start-points \\
      --custom \\
        https://github.com/cyber-dojo/custom-start-points.git

  cyber-dojo start-point create \\
    cyberdojo/exercises-start-points \\
      --exercises \\
        https://github.com/cyber-dojo/exercises-start-points.git

  cyber-dojo start-point create \\
    cyberdojo/languages-start-points-common \\
      --languages \\
        \$(curl --silent https://raw.githubusercontent.com/cyber-dojo/languages/master/url_list/common)

Additionally, .env files for nginx, and web can be overriden using
environment variables holding the .env file's absolute path.

  CYBER_DOJO_NGINX_ENV=PATH
  CYBER_DOJO_WEB_ENV=PATH

Example: specify the port and custom start-point with command-line arguments

  cyber-dojo up --port=8000 --custom=acme/my-custom:latest

Example: specify .env file for nginx
  export CYBER_DOJO_NGINX_ENV=/Users/fred/nginx.env
  cyber-dojo up"

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
  refuteUp --languages
  assertNoStdout
  assertStderrEquals 'ERROR: missing argument value --languages=[???]'
  refuteUp --languages=
  assertNoStdout
  assertStderrEquals 'ERROR: missing argument value --languages=[???]'
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____missing_custom()
{
  refuteUp --custom
  assertNoStdout
  assertStderrEquals 'ERROR: missing argument value --custom=[???]'
  refuteUp --custom=
  assertNoStdout
  assertStderrEquals 'ERROR: missing argument value --custom=[???]'
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____missing_exercises()
{
  refuteUp --exercises
  assertNoStdout
  assertStderrEquals 'ERROR: missing argument value --exercises=[???]'
  refuteUp --exercises=
  assertNoStdout
  assertStderrEquals 'ERROR: missing argument value --exercises=[???]'
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____missing_port()
{
  refuteUp --port
  assertNoStdout
  assertStderrEquals 'ERROR: missing argument value --port=[???]'
  refuteUp --port=
  assertNoStdout
  assertStderrEquals 'ERROR: missing argument value --port=[???]'
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____named_custom_does_not_exist()
{
  local -r name=not_exist
  refuteUp --custom=${name}
  assertStdoutIncludes "docker pull ${name}"
  assertStderrIncludes "ERROR: failed to pull ${name}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____named_exercises_does_not_exist()
{
  local -r name=not_exist
  refuteUp --exercises=${name}
  assertStdoutIncludes "docker pull ${name}"
  assertStderrIncludes "ERROR: failed to pull ${name}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____named_languages_does_not_exist()
{
  local -r name=not_exist
  refuteUp --languages=${name}
  assertStdoutIncludes "docker pull ${name}"
  assertStderrIncludes "ERROR: failed to pull ${name}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____named_exercises_is_not_exercise_type()
{
  local -r custom_name=test_up_custom_2
  assertStartPointCreate ${custom_name} --custom $(custom_urls)
  refuteUp --exercises=${custom_name}
  assertNoStdout
  assertStderrEquals "ERROR: the type of ${custom_name} is custom (not exercises)"
  assertStartPointRm ${custom_name}
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____unknown_arg()
{
  local -r name=salmon
  refuteUp ${name}
  assertNoStdout
  assertStderrEquals "ERROR: unknown argument [${name}]"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____unknown_args()
{
  local -r arg1=--spey
  local -r arg2=--tay
  refuteUp ${arg1}=A ${arg2}=B
  assertNoStdout
  assertStderrIncludes "ERROR: unknown argument [${arg1}]"
  assertStderrIncludes "ERROR: unknown argument [${arg2}]"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

. ${MY_DIR}/shunit2_helpers.sh
. ${MY_DIR}/shunit2
