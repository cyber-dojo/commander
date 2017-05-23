
exe=./../../cyber-dojo

github_cyber_dojo='https://github.com/cyber-dojo'

# - - - - - - - - - - - - - - - - - - - - - - - - -
# start point create
# - - - - - - - - - - - - - - - - - - - - - - - - -

startPointCreate() { ${exe} start-point create "$*" >${stdoutF} 2>${stderrF}; }

assertStartPointCreate()
{
  refuteStartPointExists $1
  startPointCreate "$*"
  assertTrue $?
  assertStartPointExists $1
}

refuteStartPointCreate()
{
  startPointCreate "$*"
  assertFalse $?
}

# - - - - - - - - - - - - - - - - - - - - - - - - -
# start point rm
# - - - - - - - - - - - - - - - - - - - - - - - - -

startPointRm() { ${exe} start-point rm $1; }

assertStartPointRm()
{
  assertStartPointExists $1
  startPointRm $1;
  assertTrue $?;
}

# - - - - - - - - - - - - - - - - - - - - - - - - -
# start point exists
# - - - - - - - - - - - - - - - - - - - - - - - - -

start_point_exists()
{
  # don't match a substring
  local start_of_line='^'
  local start_point=$1
  local end_of_line='$'
  docker volume ls --quiet | grep "${start_of_line}${start_point}${end_of_line}" > /dev/null
}

assertStartPointExists() { start_point_exists $1; assertTrue  $?; }
refuteStartPointExists() { start_point_exists $1; assertFalse $?; }

# - - - - - - - - - - - - - - - - - - - - - - - - -
# up
# - - - - - - - - - - - - - - - - - - - - - - - - -

assertUp() { ${exe} up "$*" >${stdoutF} 2>${stderrF}; assertTrue  $?; }
refuteUp() { ${exe} up "$*" >${stdoutF} 2>${stderrF}; assertFalse $?; }

# - - - - - - - - - - - - - - - - - - - - - - - - -
# down
# - - - - - - - - - - - - - - - - - - - - - - - - -

assertDown() { ${exe} down "$*" >${stdoutF} 2>${stderrF}; assertTrue  $?; }

