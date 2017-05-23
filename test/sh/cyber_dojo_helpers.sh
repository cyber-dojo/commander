
github_cyber_dojo='https://github.com/cyber-dojo'

exe=./../../cyber-dojo

up()                { ${exe} up                  $* >${stdoutF} 2>${stderrF}; }
clean()             { ${exe} clean               $* >${stdoutF} 2>${stderrF}; }
down()              { ${exe} down                $* >${stdoutF} 2>${stderrF}; }
logs()              { ${exe} logs                $* >${stdoutF} 2>${stderrF}; }
sh()                { ${exe} sh                  $* >${stdoutF} 2>${stderrF}; }
startPointCreate()  { ${exe} start-point create  $* >${stdoutF} 2>${stderrF}; }
startPointInspect() { ${exe} start-point inspect $* >${stdoutF} 2>${stderrF}; }
startPointLatest()  { ${exe} start-point latest  $* >${stdoutF} 2>${stderrF}; }
startPointRm()      { ${exe} start-point rm $1; }

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

assertStartPointRm()
{
  assertStartPointExists $1
  startPointRm $1
  assertTrue $?
}

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

assertStartPointInspect() { startPointInspect $*; assertTrue  $?; }
refuteStartPointInspect() { startPointInspect $*; assertFalse $?; }

assertStartPointLatest() { startPointLatest $*; assertTrue  $?; }
refuteStartPointLatest() { startPointLatest $*; assertFalse $?; }

assertUp() { up $*; assertTrue  $?; }
refuteUp() { up $*; assertFalse $?; }

assertDown() { down $*; assertTrue  $?; }
refuteDown() { down $*; assertFalse $?; }

assertClean() { clean $*; assertTrue  $?; }
refuteClean() { clean $*; assertFalse $?; }

assertSh() { sh $*; assertTrue  $?; }
refuteSh() { sh $*; assertFalse $?; }

assertLogs() { logs $*; assertTrue  $?; }
refuteLogs() { logs $*; assertFalse $?; }

