#!/usr/bin/env bash
set -Eeu

exit_zero_if_build_only()
{
  if [ "${1:-}" == --build-only ] || [ "${1:-}" == -bo ]; then
    exit 0
  fi
}
