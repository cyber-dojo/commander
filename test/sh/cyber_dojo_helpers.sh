
MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"

readonly github_cyber_dojo=https://github.com/cyber-dojo
readonly raw_github_cd_org=https://raw.githubusercontent.com/cyber-dojo
readonly exe="${MY_DIR}/../../cyber-dojo"

# - - - - - - - - - - - - - - - - - - - - - - - - -

CD_DIR()
{
  echo "$( cd "${MY_DIR}" && cd ../../../../cyber-dojo && pwd )"
}

CDL_DIR()
{
  echo "$(cd "${MY_DIR}" && cd ../../../../cyber-dojo-languages && pwd )"
}


on_CI()
{
  [[ ! -z "${CIRCLE_SHA1}" ]] || [[ ! -z "${TRAVIS}" ]]
}

# - - - - - - - - - - - - - - - - - - - - - - - - -

custom_urls()
{
  if on_CI; then
    echo -n "${github_cyber_dojo}/custom"
  else
    echo -n "file://$(CD_DIR)/custom"
  fi
}

# - - - - - - - - - - - - - - - - - - - - - - - - -

exercises_urls()
{
  if on_CI; then
    echo -n "${github_cyber_dojo}/exercises"
  else
    echo -n "file://$(CD_DIR)/exercises"
  fi
}

# - - - - - - - - - - - - - - - - - - - - - - - - -

languages_urls()
{
  if on_CI; then
    echo -n $(curl --silent "${raw_github_cd_org}/languages/master/url_list/small")
  else
    echo -n "file://$(CDL_DIR)/gcc-assert \
             file://$(CDL_DIR)/python-unittest \
             file://$(CDL_DIR)/ruby-minitest"
  fi
}

# - - - - - - - - - - - - - - - - - - - - - - - - -

declare -a service_names=(
  differ
  grafana
  mapper
  nginx
  prometheus
  ragger
  runner
  saver
  web
  zipper
)

# - - - - - - - - - - - - - - - - - - - - - - - - -

clean()             { ${exe} clean               $* >${stdoutF} 2>${stderrF}; }
down()              { set +e; ${exe} down                $* >${stdoutF} 2>${stderrF}; status=$?; set -e; return $status; }
logs()              { ${exe} logs                $* >${stdoutF} 2>${stderrF}; }
sh()                { ${exe} sh                  $* >${stdoutF} 2>${stderrF}; }
startPoint()        { ${exe} start-point         $* >${stdoutF} 2>${stderrF}; }
startPointCreate()  { set +e; ${exe} start-point create  $* >${stdoutF} 2>${stderrF}; status=$?; set -e; return $status; }
startPointInspect() { ${exe} start-point inspect $* >${stdoutF} 2>${stderrF}; }
startPointLs()      { ${exe} start-point ls      $* >${stdoutF} 2>${stderrF}; }
startPointRm()      { set +e; ${exe} start-point rm      $* >${stdoutF} 2>${stderrF}; status=$?; set -e; return $status; }
startPointUpdate()  { ${exe} start-point update  $* >${stdoutF} 2>${stderrF}; }
up()                { set +e; ${exe} up                  $* >${stdoutF} 2>${stderrF}; status=$?; set -e; return $status; }
update()            { ${exe} update              $* >${stdoutF} 2>${stderrF}; }

# - - - - - - - - - - - - - - - - - - - - - - - - -

assertStartPointCreate()  { startPointCreate $*; assertTrue  $?; }
refuteStartPointCreate()  { startPointCreate $*; assertFalse $?; }

assertStartPoint()        { startPoint        $*; assertTrue  $?; }
refuteStartPoint()        { set +e; startPoint        $*; assertFalse $?; set -e; }

assertStartPointInspect() { startPointInspect $*; assertTrue  $?; }
refuteStartPointInspect() { set +e; startPointInspect $*; assertFalse $?; set -e; }

assertStartPointLs()      { startPointLs      $*; assertTrue  $?; }
refuteStartPointLs()      { set +e; startPointLs      $*; assertFalse $?; set -e; }

assertStartPointRm()      { startPointRm      $*; assertTrue  $?; }
refuteStartPointRm()      { startPointRm      $*; assertFalse $?; }

assertStartPointUpdate()  { startPointUpdate  $*; assertTrue  $?; }
refuteStartPointUpdate()  { set +e; startPointUpdate  $*; assertFalse $?; set -e; }

assertStartPointExists()  { startPointExists $1; assertTrue  $?; }
refuteStartPointExists()  { set +e; startPointExists $1; assertFalse $?; set -e; }

# - - - - - - - - - - - - - - - - - - - - - - - - -

assertClean()  { clean  $*; assertTrue  $?; }
refuteClean()  { set +e; clean  $*; assertFalse $?; set -e; }

assertDown()   { down   $*; assertTrue  $?; }
refuteDown()   { down   $*; assertFalse $?; }

assertLogs()   { logs   $*; assertTrue  $?; }
refuteLogs()   { set +e; logs   $*; assertFalse $?; set -e; }

assertSh()     { sh     $*; assertTrue  $?; }
refuteSh()     { set +e; sh     $*; assertFalse $?; set -e; }

assertUp()     { up     $*; assertTrue  $?; }
refuteUp()     { up     $*; assertFalse $?; }

assertUpdate() { update $*; assertTrue  $?; }
refuteUpdate() { set +e; update $*; assertFalse $?; set -e; }

# - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - -

removeAllStartPoints()
{
  startPoints=(`${exe} start-point ls --quiet`)
  for startPoint in "${startPoints[@]}"
  do
    ${exe} start-point rm "${startPoint}"
  done
}

startPointExists()
{
  # don't match a substring
  local readonly start_of_line='^'
  local readonly name=$1
  local readonly end_of_line='$'
  docker image ls --format '{{.Repository}}:{{.Tag}}' \
    | grep "${start_of_line}${name}${end_of_line}" > /dev/null
}

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
