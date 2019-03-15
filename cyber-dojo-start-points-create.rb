
#require_relative 'cyber-dojo-start-point-create-list'
#require_relative 'cyber-dojo-start-point-create-dir'

def cyber_dojo_start_points_create
  help = [
    '',
    "Use: #{me} start-point create NAME --list=URL|FILE",
    'Creates a start-point named NAME from git-clones of all the URLs listed in URL|FILE',
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

  if [nil,'-h','--help'].include? ARGV[2]
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
  git  = get_arg('--git' , args)
  dir  = get_arg('--dir' , args)
  list = get_arg('--list', args)
  count = 0
  count += 1 if git
  count += 1 if dir
  count += 1 if list
  if count > 1
    STDERR.puts 'FAILED: specify ONE of --git= / --dir= / --list='
    exit failed
  end

  if volume_exists? vol
    STDERR.puts "A start-point called #{vol} already exists"
    exit failed
  end

  if dir
    cyber_dojo_start_point_create_dir(vol, dir)
  end

  if git
    cyber_dojo_start_point_create_list(vol, [ git ])
  end

  if list
    list = 'file://' + list if list[0] == '/'
    urls = run("curl -s #{list}").split
    cyber_dojo_start_point_create_list(vol, urls)
  end

end
