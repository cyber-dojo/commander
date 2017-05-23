
exe=./../../cyber-dojo

github_cyber_dojo='https://github.com/cyber-dojo'

# - - - - - - - - - - - - - - - - - - - - - - - - -
# start point create
# - - - - - - - - - - - - - - - - - - - - - - - - -

start_point_create()
{
  local name=$1
  local option=$2
  local value=$3
  ${exe} start-point create ${name} --${option}=${value} >${stdoutF} 2>${stderrF}
}

startPointCreateGit()  { start_point_create $1  git $2; }
startPointCreateDir()  { start_point_create $1  dir $2; }
startPointCreateList() { start_point_create $1 list $2; }

assertStartPointCreateGit() { startPointCreateGit $1 $2; assertTrue  $?; }
refuteStartPointCreateGit() { startPointCreateGit $1 $2; assertFalse $?; }

assertStartPointCreateDir() { startPointCreateDir $1 $2; assertTrue  $?; }
refuteStartPointCreateDir() { startPointCreateDir $1 $2; assertFalse $?; }

assertStartPointCreateList() { startPointCreateList $1 $2; assertTrue  $?; }
refuteStartPointCreateList() { startPointCreateList $1 $2; assertFalse $?; }

# - - - - - - - - - - - - - - - - - - - - - - - - -
# start point rm
# - - - - - - - - - - - - - - - - - - - - - - - - -

startPointRm() { ${exe} start-point rm $1; }

assertStartPointRm() { startPointRm $1; assertTrue  $?; }

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

