
MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"

readonly github_cyber_dojo=https://github.com/cyber-dojo
readonly raw_github_cd_org=https://raw.githubusercontent.com/cyber-dojo
readonly exe="${MY_DIR}/../../cyber-dojo"

# - - - - - - - - - - - - - - - - - - - - - - - - -

CD_DIR()
{
  printf "$( cd "${MY_DIR}/../../../../cyber-dojo" && pwd )"
}

CDSP_DIR()
{
  printf "$(cd "${MY_DIR}/../../../../cyber-dojo-start-points" && pwd )"
}

on_CI()
{
  [ -n "${CIRCLE_SHA1}" ]
}

# - - - - - - - - - - - - - - - - - - - - - - - - -

custom_urls()
{
  # A single Alpine-based url to help make tests faster
  if on_CI; then
    printf https://github.com/cyber-dojo-start-points/java-junit
  else
    printf "$(CDSP_DIR)/java-junit"
  fi
}

# - - - - - - - - - - - - - - - - - - - - - - - - -

exercises_urls()
{
  if on_CI; then
    printf "${github_cyber_dojo}/exercises-start-points"
  else
    printf "$(CD_DIR)/exercises-start-points"
  fi
}

# - - - - - - - - - - - - - - - - - - - - - - - - -

languages_urls()
{
  # A single Alpine-based url to help make tests faster
  if on_CI; then
    printf https://github.com/cyber-dojo-start-points/ruby-minitest
  else
    printf "$(CDSP_DIR)/ruby-minitest"
  fi
}

# - - - - - - - - - - - - - - - - - - - - - - - - -

declare -a service_names=(
  creator
  custom-chooser
  exercises-chooser
  languages-chooser
  differ
  nginx
  repler
  runner
  saver
  shas
  web
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
version()           { ${exe} version             $* >${stdoutF} 2>${stderrF}; }

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

assertVersion()           { version           $*; assert $?; }

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
  local stdout="`cat ${stdoutF}`"
  local stderr="`cat ${stderrF}`"
  echo "<stdout>${stdout}</stdout><stderr>${stderr}</stderr>"
}

assert()
{
  if [ "${1}" != '0' ]; then
    assertTrue "$(stdout_stderr)" 1
    exit 1
  fi
}

refute()
{
  if [ "${1}" == '0' ]; then
    assertFalse "$(stdout_stderr)" 0
    exit 1
  fi
}
