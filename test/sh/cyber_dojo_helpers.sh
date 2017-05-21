
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

start_point_create()
{
  local name=$1
  local option=$2
  local value=$3
  ${exe} start-point create ${name} --${option}=${value} >${stdoutF} 2>${stderrF}
}

startPointCreateGit()
{
  start_point_create $1 git $2
}

startPointCreateDir()
{
  start_point_create $1 dir $2
}

startPointCreateList()
{
  start_point_create $1 list $2
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
