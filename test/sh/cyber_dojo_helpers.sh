
exe=./../../cyber-dojo

github_cyber_dojo='https://github.com/cyber-dojo'

# - - - - - - - - - - - - - - - - - - - - - - - - -
# start point create
# - - - - - - - - - - - - - - - - - - - - - - - - -

startPointCreate() { ${exe} start-point create $* >${stdoutF} 2>${stderrF}; }

assertStartPointCreate()
{
  refuteStartPointExists $1
  startPointCreate $*
  assertTrue $?
  if [ "$*" != '' ] && [ "$*" != '--help' ]; then
    assertStartPointExists $1
  fi
}

refuteStartPointCreate()
{
  startPointCreate $*
  assertFalse $?
}

# - - - - - - - - - - - - - - - - - - - - - - - - -
# start point rm
# - - - - - - - - - - - - - - - - - - - - - - - - -

startPointRm() { ${exe} start-point rm $1; }

assertStartPointRm()
{
  assertStartPointExists $1
  startPointRm $1
  assertTrue $?
}

# - - - - - - - - - - - - - - - - - - - - - - - - -
# start point exists
# - - - - - - - - - - - - - - - - - - - - - - - - -

startPointExists()
{
  # don't match a substring
  local start_of_line='^'
  local start_point=$1
  local end_of_line='$'
  docker volume ls --quiet | grep "${start_of_line}${start_point}${end_of_line}" > /dev/null
}

assertStartPointExists() { startPointExists $1; assertTrue  $?; }
refuteStartPointExists() { startPointExists $1; assertFalse $?; }

# - - - - - - - - - - - - - - - - - - - - - - - - -
# start point inspect
# - - - - - - - - - - - - - - - - - - - - - - - - -

startPointInspect() { ${exe} start-point inspect $* >${stdoutF} 2>${stderrF}; }

assertStartPointInspect() { startPointInspect $*; assertTrue  $?; }
refuteStartPointInspect() { startPointInspect $*; assertFalse $?; }

# - - - - - - - - - - - - - - - - - - - - - - - - -
# up
# - - - - - - - - - - - - - - - - - - - - - - - - -

up() { ${exe} up "$*" >${stdoutF} 2>${stderrF}; }

assertUp() { up $*; assertTrue  $?; }
refuteUp() { up $*; assertFalse $?; }

# - - - - - - - - - - - - - - - - - - - - - - - - -
# down
# - - - - - - - - - - - - - - - - - - - - - - - - -

down() { ${exe} down "$*" >${stdoutF} 2>${stderrF}; }

assertDown() { down $*; assertTrue  $?; }

