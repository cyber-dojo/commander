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

on_Mac()
{
  # detect OS from bash: https://stackoverflow.com/questions/394230
  [[ "${OSTYPE:-}" == "darwin"* ]]
}
