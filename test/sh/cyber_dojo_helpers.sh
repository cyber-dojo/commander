
MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"

readonly github_cyber_dojo=https://github.com/cyber-dojo
readonly raw_github_cd_org=https://raw.githubusercontent.com/cyber-dojo
readonly exe="${MY_DIR}/../../cyber-dojo"

# Tests override COMMANDER_IMAGE so cyber-dojo script does
# _NOT_ get the commander-image tag from versioner:latest
export COMMANDER_IMAGE=cyberdojo/commander:latest

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
  [[ -n "${CIRCLE_SHA1}" ]] || [[ -n "${TRAVIS}" ]]
}

# - - - - - - - - - - - - - - - - - - - - - - - - -

custom_urls()
{
  if on_CI; then
    echo -n "${github_cyber_dojo}/custom"
  else
    echo -n "$(CD_DIR)/custom"
  fi
}

# - - - - - - - - - - - - - - - - - - - - - - - - -

exercises_urls()
{
  if on_CI; then
    echo -n "${github_cyber_dojo}/exercises"
  else
    echo -n "$(CD_DIR)/exercises"
  fi
}

# - - - - - - - - - - - - - - - - - - - - - - - - -

languages_urls()
{
  if on_CI; then
    echo -n $(curl --silent "${raw_github_cd_org}/languages/master/url_list/small")
  else
    echo -n "$(CDL_DIR)/gcc-assert \
             $(CDL_DIR)/python-unittest \
             $(CDL_DIR)/ruby-minitest"
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
down()              { ${exe} down                $* >${stdoutF} 2>${stderrF}; }
logs()              { ${exe} logs                $* >${stdoutF} 2>${stderrF}; }
sh()                { ${exe} sh                  $* >${stdoutF} 2>${stderrF}; }
startPoint()        { ${exe} start-point         $* >${stdoutF} 2>${stderrF}; }
startPointCreate()  { ${exe} start-point create  $* >${stdoutF} 2>${stderrF}; }
startPointInspect() { ${exe} start-point inspect $* >${stdoutF} 2>${stderrF}; }
startPointLs()      { ${exe} start-point ls      $* >${stdoutF} 2>${stderrF}; }
startPointRm()      { ${exe} start-point rm      $* >${stdoutF} 2>${stderrF}; }
startPointUpdate()  { ${exe} start-point update  $* >${stdoutF} 2>${stderrF}; }
up()                { ${exe} up                  $* >${stdoutF} 2>${stderrF}; }
update()            { ${exe} update              $* >${stdoutF} 2>${stderrF}; }

# - - - - - - - - - - - - - - - - - - - - - - - - -

assertClean()             { clean             $*; assert $?; }
refuteClean()             { clean             $*; refute $?; }

assertDown()              { down              $*; assert $?; }
refuteDown()              { down              $*; refute $?; }

assertLogs()              { logs              $*; assert $?; }
refuteLogs()              { logs              $*; refute $?; }

assertSh()                { sh                $*; assert $?; }
refuteSh()                { sh                $*; refute $?; }

assertStartPointCreate()  { startPointCreate  $*; assert $?; }
refuteStartPointCreate()  { startPointCreate  $*; refute $?; }

assertStartPoint()        { startPoint        $*; assert $?; }
refuteStartPoint()        { startPoint        $*; refute $?; }

assertStartPointInspect() { startPointInspect $*; assert $?; }
refuteStartPointInspect() { startPointInspect $*; refute $?; }

assertStartPointLs()      { startPointLs      $*; assert $?; }
refuteStartPointLs()      { startPointLs      $*; refute $?; }

assertStartPointRm()      { startPointRm      $*; assert $?; }
refuteStartPointRm()      { startPointRm      $*; refute $?; }

assertStartPointUpdate()  { startPointUpdate  $*; assert $?; }
refuteStartPointUpdate()  { startPointUpdate  $*; refute $?; }

assertUp()                { up                $*; assert $?; }
refuteUp()                { up                $*; refute $?; }

assertUpdate()            { update            $*; assert $?; }
refuteUpdate()            { update            $*; refute $?; }

# - - - - - - - - - - - - - - - - - - - - - - - - -

assertStartPointExists()  { startPointExists  $1; assert $?; }
refuteStartPointExists()  { startPointExists  $1; refute $?; }

startPointExists()
{
  # don't match a substring
  local -r start_of_line='^'
  local -r name=$1
  local -r end_of_line='$'
  docker image ls --format '{{.Repository}}:{{.Tag}}' \
    | grep "${start_of_line}${name}${end_of_line}" > /dev/null
}

removeAllStartPoints()
{
  local -r startPoints=(`${exe} start-point ls --quiet`)
  for startPoint in "${startPoints[@]}"
  do
    ${exe} start-point rm "${startPoint}"
  done
}

# - - - - - - - - - - - - - - - - - - - - - - - - -

stdout_stderr()
{
  echo "<stdout>${stdoutF}</stdout><stderr>${stderrF}</stderr>"
}

assert()
{
  if [ "$1" != "0" ]; then
    assertTrue $(stdout_stderr) 1
    exit 1
  fi
}

refute()
{
  if [ "$1" == "0" ]; then
    assertFalse $(stdout_stderr) 0
    exit 1
  fi
}
