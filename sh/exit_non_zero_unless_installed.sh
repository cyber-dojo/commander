
exit_non_zero_unless_installed()
{
  for tool in "$@"; do
    if ! installed "${tool}" ; then
      echo_stderr "ERROR: ${tool} is not installed!"
      exit 42
    fi
  done
}

installed()
{
  if hash "${1}" 2> /dev/null; then
    true
  else
    false
  fi
}
