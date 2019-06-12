#!/bin/bash

MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"
. ${MY_DIR}/cyber_dojo_helpers.sh

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_VERSION() { :; }

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test___success() { :; }

test_____update_to_public_release()
{
  # don't use cyberdojo/commander:latest
  unset COMMANDER_TAG
  assertUpdate 0.0.2
  assertVersion
  export COMMANDER_TAG=latest
  assertStdoutIncludes 'Version: 0.0.2'
  assertStdoutIncludes 'Type: public'
  assertStdoutIncludes 'Created: 2019-06-12 18:00:19'
  assertNoStderr
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

X_test_____update_to_development_tag()
{
  # don't use cyberdojo/commander:latest
  unset COMMANDER_TAG
  assertUpdate XXXXXXX # needs a development tag that has version in it!
  assertVersion
  export COMMANDER_TAG=latest
  assertStdoutIncludes 'Version: 5e3bc0b'
  assertStdoutIncludes 'Type: development'
  assertStdoutIncludes 'Created: 2019-06-07 09:07:09'
  assertNoStderr
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

. ${MY_DIR}/shunit2_helpers.sh
. ${MY_DIR}/shunit2
