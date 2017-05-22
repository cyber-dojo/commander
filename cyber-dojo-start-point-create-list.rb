
$g_vol = ''
$g_cid = ''

def cyber_dojo_start_point_create_list(name, urls)

  # make an empty docker volume
  run_loud "docker volume create --name=#{name} --label=cyber-dojo-start-point"
  $g_vol = name

  # mount empty docker volume inside docker container
  command = [
    'docker create',
      '--interactive',
      '--user=root',
      "--volume=#{name}:/data",
      "#{cyber_dojo_commander}",
      'sh'
  ].join(space)
  $g_cid = run_loud(command).strip
  run_loud "docker start #{$g_cid}"

  # pull git repos into docker volume
  urls.each { |url| start_point_git_sparse_pull(url) }

  # ensure cyber-dojo user owns everything in the volume
  run_loud "docker exec #{$g_cid} sh -c 'chown -R cyber-dojo:cyber-dojo /data'"

  # check the volume is a good start-point
  run_quiet "docker exec #{$g_cid} sh -c './start_point_check.rb /data'"
  #if $exit_status != 0
  #  clean_up
  #  exit failed
  #end

  # TODO: put in rescue statement?
  # 6. clean up everything used to create the volume, but not the volume itself
  $g_vol = ''
  clean_up
end

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

def start_point_git_sparse_pull(url)
  name = url.split('/')[-1]
  dir = '/data/' + name
  commands = [
    "mkdir #{dir}",
    "cd #{dir} && git init",
    "cd #{dir} && git remote add origin #{url}",
    "cd #{dir} && git config core.sparseCheckout true",
    "cd #{dir} && echo !\\*\\*/_docker_context >> .git/info/sparse-checkout",
    "cd #{dir} && echo /\\*                    >> .git/info/sparse-checkout",
    "cd #{dir} && git pull --depth=1 origin master &> /dev/null",
    "cd #{dir} && rm -rf .git",
    "cd #{dir} && cp setup.json .."
  ]
  commands.each do |cmd|
    command = "docker exec #{$g_cid} sh -c '#{cmd}'"
    output = run_loud(command)
  end
end

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

def run_loud(command)
  assert_run(command) { STDERR.puts "#{command} failed!?" }
end

def run_quiet(command)
  assert_run(command) { }
end

def assert_run(command)
  output = run(command)
  if $exit_status != 0
    clean_up
    yield
    exit failed
  end
  output
end

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

def clean_up
  me = __method__.to_s

  # Remove docker container?
  if $g_cid != ''
    debug "#{me}: doing [docker rm -f $g_cid]"
    run "docker rm -f #{$g_cid} > /dev/null 2>&1"
  else
    debug "#{me}: NOT doing [docker rm -f $g_cid]"
  end

  # Remove docker volume?
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

