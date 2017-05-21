
$g_vol = ''
$g_cid = ''

def cyber_dojo_start_point_create_list(name, list)

  if volume_exists? name
    StDERR.puts "A start-point called #{name} already exists"
    exit failed
  end

  list_content = %w(
    https://github.com/cyber-dojo-languages/elm-test
    https://github.com/cyber-dojo-languages/haskell-hunit
  )

  # 1. make an empty docker volume
  command="docker volume create --name=#{name} --label=cyber-dojo-start-point"
  run(command)
  if $exit_status != 0
    clean_up
    STDERR.puts "${command} FAILED"
    exit failed
  end
  $g_vol = name

  # 2. mount empty docker volume inside docker container
  command = [
    'docker create',
      '--interactive',
      '--user=root',
      "--volume=#{name}:/data",
      "#{cyber_dojo_commander}",
      'sh'
  ].join(space)
  $g_cid = run command
  command = "docker start #{$g_cid}"
  run command
  if $exit_status != 0
    clean_up
    STDERR.puts "#{command} failed!?"
    exit failed
  end


  # ...

  # 6. clean up everything used to create the volume, but not the volume itself
  $g_vol = ''
  clean_up
end

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

def clean_up
  me = 'clean_up'

  # remove docker container?
  if $g_cid != ''
    debug "#{me}: doing [docker rm -f $g_cid]"
    run "docker rm -f #{$g_cid} > /dev/null 2>&1"
  else
    debug "#{me}: NOT doing [docker rm -f $g_cid]"
  end

  # remove docker volume?
  if $g_vol != ''
    debug "#{me}: doing [docker volume rm $g_vol]"
    # previous [docker rm] command seems to sometimes complete
    # before it is safe to remove its volume?!
    sleep 1
    run "docker volume rm #{$g_vol} > /dev/null 2>&1"
  else
    debug "#{me}: NOT doing [docker volume rm $g_vol]"
  end
end

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

def debug(diagnostic)
  if $debug_on
    STDERR.puts diagnostic
  end
end

