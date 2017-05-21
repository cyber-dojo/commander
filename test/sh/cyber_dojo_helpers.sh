
exe=./../../cyber-dojo

github_cyber_dojo='https://github.com/cyber-dojo'

start_point_exists()
{
  # don't match a substring
  local start_of_line='^'
  local start_point=$1
  local end_of_line='$'
  docker volume ls --quiet | grep "${start_of_line}${start_point}${end_of_line}" > /dev/null
  #return $?
}

startPointRm()
{
  local name=$1
  ${exe} start-point rm ${name}
}

assertStartPointExists()
{
  local name=$1
  start_point_exists ${name}
  assertTrue $?
}

refuteStartPointExists()
{
  local name=$1
  start_point_exists ${name}
  assertFalse $?
}
