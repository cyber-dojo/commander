
github_cyber_dojo='https://github.com/cyber-dojo'

exe=./../../cyber-dojo

up()                { ${exe} up                  $* >${stdoutF} 2>${stderrF}; }
clean()             { ${exe} clean               $* >${stdoutF} 2>${stderrF}; }
down()              { ${exe} down                $* >${stdoutF} 2>${stderrF}; }
startPointCreate()  { ${exe} start-point create  $* >${stdoutF} 2>${stderrF}; }
startPointInspect() { ${exe} start-point inspect $* >${stdoutF} 2>${stderrF}; }
startPointLatest()  { ${exe} start-point latest  $* >${stdoutF} 2>${stderrF}; }
startPointRm()      { ${exe} start-point rm $1; }

# - - - - - - - - - - - - - - - - - - - - - - - - -
# start point create
# - - - - - - - - - - - - - - - - - - - - - - - - -

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

assertStartPointInspect() { startPointInspect $*; assertTrue  $?; }
refuteStartPointInspect() { startPointInspect $*; assertFalse $?; }

# - - - - - - - - - - - - - - - - - - - - - - - - -
# start point latest
# - - - - - - - - - - - - - - - - - - - - - - - - -

assertStartPointLatest() { startPointLatest $*; assertTrue  $?; }
refuteStartPointLatest() { startPointLatest $*; assertFalse $?; }

# - - - - - - - - - - - - - - - - - - - - - - - - -
# up
# - - - - - - - - - - - - - - - - - - - - - - - - -

assertUp() { up $*; assertTrue  $?; }
refuteUp() { up $*; assertFalse $?; }

# - - - - - - - - - - - - - - - - - - - - - - - - -
# down
# - - - - - - - - - - - - - - - - - - - - - - - - -

assertDown() { down $*; assertTrue  $?; }

# - - - - - - - - - - - - - - - - - - - - - - - - -
# clean
# - - - - - - - - - - - - - - - - - - - - - - - - -

assertClean() { clean $*; assertTrue  $?; }
refuteClean() { clean $*; assertFalse $?; }

