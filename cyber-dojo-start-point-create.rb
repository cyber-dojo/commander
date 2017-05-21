
def cyber_dojo_start_point_create
  help = [
    '',
    "Use: #{me} start-point create NAME --list=FILE",
    'Creates a start-point named NAME from the URLs listed in FILE',
    '',
    "Use: #{me} start-point create NAME --git=URL",
    'Creates a start-point named NAME from a git clone of URL',
    '',
    "Use: #{me} start-point create NAME --dir=DIR",
    'Creates a start-point named NAME from a copy of DIR',
    '',
    "NAME's first letter must be [a-zA-Z0-9]",
    "NAME's remaining letters must be [a-zA-Z0-9_.-]",
    "NAME must be at least two letters long"
  ]

  if [nil,'--help'].include? ARGV[2]
    show help
    exit succeeded
  end

  # If you do
  #   [docker volume create --name=-name=sdsd]
  # You get: Error response from daemon: create --name=sdsd: "--name=sdsd"
  #          includes invalid characters for a local volume name,
  #          only "[a-zA-Z0-9][a-zA-Z0-9_.-]" are allowed
  # Experimenting with [docker volume create] reveals this means
  #   [a-zA-Z0-9] for the first letter
  #   [a-zA-Z0-9_.-] for the *remaining* letters
  # Docker volume names must be at least 2 letters long.
  # See https://github.com/docker/docker/issues/20122'

  vol = ARGV[2]
  unless vol =~ /^[a-zA-Z0-9][a-zA-Z0-9_.-]+$/
    STDERR.puts "FAILED: #{vol} is an illegal NAME"
    exit failed
  end

  if volume_exists? vol
    STDERR.puts "FAILED: a start-point called #{vol} already exists"
    exit failed
  end

  # unknown arguments?
  args = ARGV[3..-1]
  knowns = ['git','dir','list']
  unknown = args.select do |argv|
    knowns.none? { |known| argv.start_with?('--' + known + '=') }
  end
  unless unknown == []
    unknown.each { |arg| STDERR.puts "FAILED: unknown argument [#{arg.split('=')[0]}]" }
    exit failed
  end

  # required known arguments
  url  = get_arg('--git' , args)
  dir  = get_arg('--dir' , args)
  list = get_arg('--list', args)
  count = 0
  count += 1 if url
  count += 1 if dir
  count += 1 if list
  if count > 1
    STDERR.puts 'FAILED: specify ONE of --git= / --dir= / --list='
    exit failed
  end

  # [cyber-dojo] does actual [start-point create NAME --dir=DIR]
  # [cyber-dojo.sh] does actual [start-point create NAME --git=URL]

  if list
    cyber_dojo_start_point_create_list vol, list
  end

end

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

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

