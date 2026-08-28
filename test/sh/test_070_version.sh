#!/bin/bash

MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"
. ${MY_DIR}/cyber_dojo_helpers.sh

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_VERSION() { :; }

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test___success() { :; }

test_____update_to_ABC_public_semantic_version()
{
  assertUpdate "$(oldest_runnable_release)"
  assertVersion
  assertStdoutIncludes "Version: $(oldest_runnable_release)"
  assertStdoutIncludes 'Type: public'
  assertStdoutIncludes 'Created: 2023-03-25 21:08:18'

  assertUpdate 0.1.330
  assertVersion
  assertStdoutIncludes 'Version: 0.1.330'
  assertStdoutIncludes 'Type: public'
  assertStdoutIncludes 'Created: 2023-09-05 11:47:12'
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____update_to_TAG_development_sha7_version()
{
  # 660b4b6 is built from a commit carrying no RELEASE, so it reports as
  # development. Its commander is the oldest runnable release's.
  assertUpdate 660b4b6
  assertVersion
  assertStdoutIncludes 'Version: 660b4b6'
  assertStdoutIncludes 'Type: development'
  assertStdoutIncludes 'Created: 2023-03-26 07:10:16'
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

. ${MY_DIR}/shunit2_helpers.sh
. ${MY_DIR}/shunit2
