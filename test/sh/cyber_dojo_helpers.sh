
MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"

readonly github_cyber_dojo=https://github.com/cyber-dojo
readonly exe="${MY_DIR}/../../cyber-dojo"

# - - - - - - - - - - - - - - - - - - - - - - - - -
# Use Alpine-based url to help make tests faster

   custom_urls() { printf 01d6142@https://github.com/cyber-dojo-start-points/java-junit; }
exercises_urls() { printf "${github_cyber_dojo}/exercises-start-points"; }
languages_urls() { printf https://github.com/cyber-dojo-start-points/ruby-minitest; }

# - - - - - - - - - - - - - - - - - - - - - - - - -

declare -a service_names=(
  creator
  differ
  nginx
  runner
  saver
  version-reporter
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
  # Get rid of pesky WARNING: .... host platform mismatch ...
  local -r startPoints=(`${exe} start-point ls --quiet 2>/dev/null`)
  for startPoint in "${startPoints[@]}"
  do
    echo "Removing ... ${startPoint}"
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
