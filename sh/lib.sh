#!/usr/bin/env bash
set -Eeu

on_ci()
{
  [ "${CI:-}" == true ]
}

echo_stderr()
{
  local -r message="${1}"
  >&2 echo "${message}"
}
