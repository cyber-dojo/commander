
MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"
CD_DIR="$( cd "${MY_DIR}" && cd ../../../../cyber-dojo && pwd )"
CDL_DIR="$(cd "${MY_DIR}" && cd ../../../../cyber-dojo-languages && pwd )"

readonly github_cyber_dojo=https://github.com/cyber-dojo
readonly raw_github_cd_org=https://raw.githubusercontent.com/cyber-dojo

readonly exe="${MY_DIR}/../../cyber-dojo"

# - - - - - - - - - - - - - - - - - - - - - - - - -

on_CI()
{
  [[ ! -z "${CIRCLE_SHA1}" ]]
}

custom_urls()
{
  if on_CI; then
    echo -n "${github_cyber_dojo}/custom"
  else
    echo -n "file://${CD_DIR}/custom"
  fi
}

exercises_urls()
{
  if on_CI; then
    echo -n "${github_cyber_dojo}/exercises"
  else
    echo -n "file://${CD_DIR}/exercises"
  fi
}

languages_urls()
{
  if on_CI; then
    echo -n $(curl --silent "${raw_github_cd_org}/languages/master/url_list/small")
  else
    echo -n "file://${CDL_DIR}/gcc-assert \
             file://${CDL_DIR}/python-unittest \
             file://${CDL_DIR}/ruby-minitest"
  fi
}

# - - - - - - - - - - - - - - - - - - - - - - - - -

declare -a service_names=(
  custom
  differ
  exercises
  grafana
  languages
  mapper
  nginx
  prometheus
  runner
  saver
  web
  zipper
)

# - - - - - - - - - - - - - - - - - - - - - - - - -

clean()             { ${exe} clean               $* >${stdoutF} 2>${stderrF}; }
down()              { ${exe} down                $* >${stdoutF} 2>${stderrF}; }
logs()              { ${exe} logs                $* >${stdoutF} 2>${stderrF}; }
sh()                { ${exe} sh                  $* >${stdoutF} 2>${stderrF}; }
startPoint()        { ${exe} start-point         $* >${stdoutF} 2>${stderrF}; }
startPointCreate()  { ${exe} start-point create  $* >${stdoutF} 2>${stderrF}; }
startPointInspect() { ${exe} start-point inspect $* >${stdoutF} 2>${stderrF}; }
#startPointLatest()  { ${exe} start-point latest  $* >${stdoutF} 2>${stderrF}; }
startPointLs()      { ${exe} start-point ls      $* >${stdoutF} 2>${stderrF}; }
startPointRm()      { ${exe} start-point rm      $* >${stdoutF} 2>${stderrF}; }
startPointUpdate()  { ${exe} start-point update  $* >${stdoutF} 2>${stderrF}; }
up()                { ${exe} up                  $* >${stdoutF} 2>${stderrF}; }
update()            { ${exe} update              $* >${stdoutF} 2>${stderrF}; }

# - - - - - - - - - - - - - - - - - - - - - - - - -

assertStartPointCreate() { startPointCreate   $*; assertTrue  $?; }
refuteStartPointCreate() { startPointCreate   $*; assertFalse $?; }

assertStartPoint()        { startPoint        $*; assertTrue  $?; }
refuteStartPoint()        { startPoint        $*; assertFalse $?; }

assertStartPointInspect() { startPointInspect $*; assertTrue  $?; }
refuteStartPointInspect() { startPointInspect $*; assertFalse $?; }

#assertStartPointLatest()  { startPointLatest  $*; assertTrue  $?; }
#refuteStartPointLatest()  { startPointLatest  $*; assertFalse $?; }

assertStartPointLs()      { startPointLs      $*; assertTrue  $?; }
refuteStartPointLs()      { startPointLs      $*; assertFalse $?; }

assertStartPointRm()      { startPointRm      $*; assertTrue  $?; }
refuteStartPointRm()      { startPointRm      $*; assertFalse $?; }

assertStartPointUpdate()  { startPointUpdate  $*; assertTrue  $?; }
refuteStartPointUpdate()  { startPointUpdate  $*; assertFalse $?; }

# - - - - - - - - - - - - - - - - - - - - - - - - -

assertClean()  { clean  $*; assertTrue  $?; }
refuteClean()  { clean  $*; assertFalse $?; }

assertDown()   { down   $*; assertTrue  $?; }
refuteDown()   { down   $*; assertFalse $?; }

assertLogs()   { logs   $*; assertTrue  $?; }
refuteLogs()   { logs   $*; assertFalse $?; }

assertSh()     { sh     $*; assertTrue  $?; }
refuteSh()     { sh     $*; assertFalse $?; }

assertUp()     { up     $*; assertTrue  $?; }
refuteUp()     { up     $*; assertFalse $?; }

assertUpdate() { update $*; assertTrue  $?; }
refuteUpdate() { update $*; assertFalse $?; }

# - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - -

startPointExists()
{
  # don't match a substring
  local readonly start_of_line='^'
  local readonly start_point=$1
  local readonly end_of_line='$'
  docker volume ls --quiet | grep "${start_of_line}${start_point}${end_of_line}" > /dev/null
}

assertStartPointExists()  { startPointExists  $1; assertTrue  $?; }
refuteStartPointExists()  { startPointExists  $1; assertFalse $?; }

# - - - - - - - - - - - - - - - - - - - - - - - - -

assert()
{
  if [ "$1" == "0" ]; then
    echo "<stdout>"
    cat ${stdoutF}
    echo "</stdout>"
    echo "<stderr>"
    cat ${stderrF}
    echo "</stderr>"
    #TODO: print 'original' arguments
    assertTrue 1
  fi
}

refute()
{
  if [ "$1" == "0" ]; then
    echo "<stdout>"
    cat ${stdoutF}
    echo "</stdout>"
    echo "<stderr>"
    cat ${stderrF}
    echo "</stderr>"
    #TODO: print 'original' arguments
    assertFalse 0
  fi
}
