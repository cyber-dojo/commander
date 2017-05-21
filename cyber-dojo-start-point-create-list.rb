
$g_vol = ''
$g_cid = ''

def cyber_dojo_start_point_create_list(name, list)

  if volume_exists? name
    StDERR.puts "A start-point called #{name} already exists"
    exit failed
  end

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
  $g_cid = run(command).strip
  command = "docker start #{$g_cid}"
  run command
  if $exit_status != 0
    clean_up
    STDERR.puts "#{command} failed!?"
    exit failed
  end

  # 3. pull git repos into docker volume
  list_urls = %w(
    https://github.com/cyber-dojo-languages/elm-test
    https://github.com/cyber-dojo-languages/haskell-hunit
  )
  list_urls.each_with_index do |url, index|
    start_point_git_sparse_pull url, index
  end

  # 4. ensure cyber-dojo user owns everything in the volume
  command = "docker exec #{$g_cid} sh -c 'chown -R cyber-dojo:cyber-dojo /data'"
  run command
  if $exit_status != 0
    clean_up
    STDERR.puts "#{command} failed!?"
    exit failed
  end

  # 5. check the volume is a good start-point
  command = "docker exec #{$g_cid} sh -c './start_point_check.rb /data'"
  run command
  if $exit_status != 0
    clean_up
    STDERR.puts "#{command} failed!?"
    exit failed
  end

  # TODO: put in rescue statement
  # 6. clean up everything used to create the volume, but not the volume itself
  $g_vol = ''
  clean_up
end

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

def start_point_git_sparse_pull(url, index)
  commands = [
    "cd /data && mkdir #{index}",
    "cd /data/#{index} && git init",
    "cd /data/#{index} && git remote add origin #{url}",
    "cd /data/#{index} && git config core.sparseCheckout true",
    "cd /data/#{index} && echo !\\*\\*/_docker_context >> .git/info/sparse-checkout",
    "cd /data/#{index} && echo /\\*                    >> .git/info/sparse-checkout",
    "cd /data/#{index} && git pull --depth=1 origin master &> /dev/null",
    "cd /data/#{index} && rm -rf .git",
    "cd /data/#{index} && cp setup.json .."
  ]
  commands.each do |cmd|
    command = "docker exec #{$g_cid} sh -c '#{cmd}'"
    output = run(command)
    #STDERR.puts command
    #STDERR.puts ":#{output}:"
    #STDERR.puts ":#{$exit_status}:"
    if $exit_status != 0
      clean_up
      STDERR.puts "#{command} failed!?"
      exit failed
    end
  end
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

