#!/bin/bash

MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"
. ${MY_DIR}/cyber_dojo_helpers.sh

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_VERSION() { :; }

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test___success() { :; }

test_____update_to_ABC_public_semantic_version()
{
  assertUpdate 0.0.2
  assertVersion
  assertStdoutIncludes 'Version: 0.0.2'
  assertStdoutIncludes 'Type: public'
  assertStdoutIncludes 'Created: 2019-06-12 18:00:19'

  assertUpdate 0.0.4
  assertVersion
  assertStdoutIncludes 'Version: 0.0.4'
  assertStdoutIncludes 'Type: public'
  assertStdoutIncludes 'Created: 2019-06-16 07:35:46'
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_____update_to_TAG_development_sha7_version()
{
  assertUpdate 677df27
  assertVersion
  assertStdoutIncludes 'Version: 677df27'
  assertStdoutIncludes 'Type: development'
  assertStdoutIncludes 'Created: 2019-06-16 07:29:16'
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

. ${MY_DIR}/shunit2_helpers.sh
. ${MY_DIR}/shunit2
