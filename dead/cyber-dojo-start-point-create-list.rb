
def cyber_dojo_start_point_create_list(name, urls)
  cid = ''
  vol = ''

  # make an empty docker volume
  assert_run_loud "docker volume create --name=#{name} --label=cyber-dojo-start-point"
  vol = name

  # mount empty docker volume inside docker container
  command = [
    'docker create',
      '--interactive',
      '--user=root',
      "--volume=#{name}:/data",
      "#{cyber_dojo_commander}",
      'sh'
  ].join(space)
  cid = assert_run_loud(command).strip
  assert_run_loud "docker start #{cid}"

  # pull git repos into docker volume
  urls.each_with_index do |url,index|
    STDOUT.puts url
    start_point_git_sparse_pull(url, index, cid)
  end

  # ensure cyber-dojo user owns everything in the volume
  assert_run_loud "docker exec #{cid} sh -c 'chown -R cyber-dojo:cyber-dojo /data'"

  # is the volume a good start-point?
  assert_run_quiet "docker exec #{cid} sh -c './start_point_check.rb /data'"
  vol = '' # yes

ensure
  clean_up(cid, vol)
end

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

def start_point_git_sparse_pull(url, index, cid)
  # The sparse-pull is done not by specifying what we
  # do want but by what we don't want. This is because
  # it has to work for all three start-point types.
  name = url.split('/')[-1]
  dir = "/data/#{index}_#{name}"
  sparse = '.git/info/sparse-checkout'
  commands = [
    "mkdir #{dir}",
    "cd #{dir} && git init",
    "cd #{dir} && git remote add origin #{url}",
    "cd #{dir} && git config core.sparseCheckout true",
    "cd #{dir} && echo !\\*\\*/docker/\\*          >> #{sparse}",
    "cd #{dir} && echo !\\*\\*/_docker_context/\\* >> #{sparse}",
    "cd #{dir} && echo /\\*                        >> #{sparse}",
    "cd #{dir} && git pull --depth=1 origin master &> /dev/null",
    "cd #{dir} && rm -rf .git",
    "cd #{dir} && rm -f README.md LICENSE.md",
    "cd #{dir} && cp start_point_type.json .."
  ]
  commands.each do |cmd|
    command = "docker exec #{cid} sh -c '#{cmd}'"
    output = assert_run_loud(command)
  end
end

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

def assert_run_loud(command)
  assert_run(command) { STDERR.puts "#{command} failed!?" }
end

def assert_run_quiet(command)
  assert_run(command) { }
end

def assert_run(command)
  output = run(command)
  if $exit_status != 0
    yield
    exit failed
  end
  output
end

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

def clean_up(cid, vol)
  me = __method__.to_s

  # Remove docker container?
  if cid != ''
    debug "#{me}: doing [docker rm -f #{cid}]"
    run "docker rm -f #{cid} > /dev/null 2>&1"
  else
    debug "#{me}: NOT doing [docker rm -f cid]"
  end

  # Remove docker volume?
  if vol != ''
    debug "#{me}: doing [docker volume rm #{vol}]"
    # previous [docker rm] command seems to sometimes complete
    # before it is safe to remove its volume? so pausing.
    sleep 1
    run "docker volume rm #{vol} > /dev/null 2>&1"
  else
    debug "#{me}: NOT doing [docker volume rm vol]"
  end
end

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

def debug(diagnostic)
  if $debug_on
    STDERR.puts diagnostic
  end
end
