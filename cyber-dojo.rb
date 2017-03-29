#!/usr/bin/env ruby

# Called from cyber-dojo.sh
# Returns non-zero to indicate cyber-dojo.sh should not proceed.

require 'json'
require 'tempfile'

$exit_status = 0

if ARGV[0] == '--debug'
  $debug_on = true
  ARGV.shift
else
  $debug_on = false
end

# - - - - - - - - - - - - - - - - - - - - - - - - - - -

def succeeded; 0; end

def failed; 1; end

def me; 'cyber-dojo'; end

def cyber_dojo_hub; 'cyberdojo'; end

def space; ' '; end

def tab; space * 4; end

def minitab; space * 2; end

def show(lines); lines.each { |line| puts line }; print "\n"; end

def quoted(s); '"' + s + '"'; end

def cyber_dojo_commander; "cyberdojo/commander"; end

def web_container_name; 'cyber-dojo-web'; end

def web_server_running; `docker ps --quiet --filter "name=#{web_container_name}"` != ''; end

def read_only; 'ro'; end

def run(command)
  output = `#{command}`
  $exit_status = $?.exitstatus
  if $debug_on
    STDERR.puts command
    puts $exit_status
    STDERR.puts output
  end
  output
end

def get_arg(name, argv)
  # eg name: --git
  #    argv: --git=URL
  #    ====> returns URL
  args = argv.select{ |arg| arg.start_with?(name + '=')}.map{ |arg| arg.split('=')[1] || '' }
  args.size == 1 ? args[0] : nil
end

#==========================================================
# $ ./cyber-dojo update
#==========================================================

def update
  help = [
    '',
    "Use: #{me} update",
    '',
    'Updates all cyber-dojo docker images and the cyber-dojo script file'
  ]

  if ARGV[1] == '--help'
    show help
    exit succeeded
  end

  unless ARGV[1].nil?
    STDERR.puts "FAILED: unknown argument [#{ARGV[1]}]"
    exit failed
  end
end

# - - - - - - - - - - - - - - - - - - - - - - - - -

def update_images
  # special command called directly from ./cyber-dojo
  # I'd like to get these image names directly from docker-compose.yml
  # but there does not seem to be a simple way to do that :-(
  service_images = [
    'nginx:latest',
    'web:latest',
    'runner:latest',
    'storer:latest',
    'differ:latest',
    'collector:latest',
    'zipper:latest',
    'prometheus:latest',
    'grafana:latest'
  ]
  service_images.each do |name|
    command = "docker pull cyberdojo/#{name}"
    # use system() so pulls are visible in terminal
    system(command)
  end

  cmd = "docker images --format '{{.Repository}}' | grep cyberdojofoundation"
  stdout = `#{cmd}`
  language_images = stdout.split("\n")
  language_images.each do |name|
    command = "docker pull #{name}"
    system(command)
  end
end

#==========================================================
# $ ./cyber-dojo clean
#==========================================================

def clean
  help = [
    '',
    "Use: #{me} clean",
    '',
    'Removes dangling docker images/volumes and exited containers',
  ]

  if ARGV[1] == '--help'
    show help
    exit succeeded
  end

  unless ARGV[1].nil?
    STDERR.puts "FAILED: unknown argument [#{ARGV[1]}]"
    exit failed
  end

  command = "docker images --quiet --filter='dangling=true' | xargs --no-run-if-empty docker rmi --force"
  run command
  command = "docker ps --all --quiet --filter='status=exited' | xargs --no-run-if-empty docker rm --force"
  run command

  # TODO: Bug - this removes start-point volumes
  #command = "docker volume ls --quiet --filter='dangling=true' | xargs --no-run-if-empty docker volume rm"
  #run command
end

#==========================================================
# $ ./cyber-dojo down
#==========================================================

def down
  help = [
    '',
    "Use: #{me} down",
    '',
    "Stops and removes docker containers created with 'up'",
  ]

  if ARGV[1] == '--help'
    show help
    exit succeeded
  end

  unless ARGV[1].nil?
    STDERR.puts "FAILED: unknown argument [#{ARGV[1]}]"
    exit failed
  end
  # cyber-dojo.sh does actual [down]
end

#==========================================================
# $ ./cyber-dojo sh
#==========================================================

def sh
  help = [
    '',
    "Use: #{me} sh",
    '',
    "Shells into the cyber-dojo web server docker container",
  ]

  if ARGV[1] == '--help'
    show help
    exit succeeded
  end

  unless ARGV[1].nil?
    STDERR.puts "FAILED: unknown argument [#{ARGV[1]}]"
    exit failed
  end

  unless web_server_running
    puts "FAILED: cannot shell in - the web server is not running"
    exit failed
  end
  # cyber-dojo.sh does actual [sh]
end

#==========================================================
# $ ./cyber-dojo logs
#==========================================================

def logs
  help = [
    '',
    "Use: #{me} logs",
    '',
    "Fetches and prints the logs of the web server (if running)",
  ]
  if ARGV[1] == '--help'
    show help
    exit succeeded
  end

  unless ARGV[1].nil?
    STDERR.puts "FAILED: unknown argument [#{ARGV[1]}]"
    exit failed
  end

  unless web_server_running
    puts "FAILED: cannot show logs - the web server is not running"
    exit failed
  else
    puts `docker logs #{web_container_name}`
  end
end

#==========================================================
# $ ./cyber-dojo up
#==========================================================

def up_arg_int_ok(help, args, name)
  integer_value = get_arg("--#{name}", args)
  if integer_value.nil?
    return true
  end

  if integer_value == ''
    STDERR.puts "FAILED: missing argument value --#{name}=[???]"
    return false
  end

  # TODO: Do we want to validate that it's an integer?

  return true
end

# - - - - - - - - - - - - - - - - - - - - - - - - -

def up_arg_ok(help, args, name)
  vol = get_arg("--#{name}", args)
  if vol.nil? || vol == name # handled in cyber-dojo.sh
    return true
  end

  if vol == ''
    STDERR.puts "FAILED: missing argument value --#{name}=[???]"
    return false
  end
  unless volume_exists?(vol)
    STDERR.puts "FAILED: start-point #{vol} does not exist"
    return false
  end
  type = cyber_dojo_type(vol)
  if type != name
    STDERR.puts "FAILED: #{vol} is not a #{name} start-point (it's type from setup.json is #{type})"
    return false
  end
  return true
end

# - - - - - - - - - - - - - - - - - - - - - - - - -

def up
  help = [
    '',
    "Use: #{me} up [OPTIONS]",
    '',
    'Creates and starts the cyber-dojo server using named/default start-points',
    '',
    minitab + '--languages=START-POINT  Specify the languages start-point.',
    minitab + "                         Defaults to a start-point named 'languages' created from",
    minitab + '                         https://github.com/cyber-dojo/start-points-languages.git',
    '',
    minitab + '--exercises=START-POINT  Specify the exercises start-point.',
    minitab + "                         Defaults to a start-point named 'exercises' created from",
    minitab + '                         https://github.com/cyber-dojo/start-points-exercises.git',
    '',
    minitab + '--custom=START-POINT     Specify the custom start-point.',
    minitab + "                         Defaults to a start-point named 'custom' created from",
    minitab + '                         https://github.com/cyber-dojo/start-points-custom.git',
    '',
    minitab + '--port=LISTEN-PORT       Specify port to listen on.',
    minitab + "                         Defaults to 80"
  ]

  if ARGV[1] == '--help'
    show help
    exit succeeded
  end

  # unknown arguments?
  args = ARGV[1..-1]
  knowns = ['languages','exercises','custom','port']
  unknown = args.select do |arg|
    knowns.none? { |known| arg.start_with?('--' + known + '=') }
  end
  unless unknown == []
    unknown.each { |arg| STDERR.puts "FAILED: unknown argument [#{arg.split('=')[0]}]" }
    exit failed
  end

  # explicit start-points?
  exit failed unless up_arg_ok(help, args, 'languages')  # --languages=NAME
  exit failed unless up_arg_ok(help, args, 'exercises')  # --exercises=NAME
  exit failed unless up_arg_ok(help, args,    'custom')  # --custom=NAME
  exit failed unless up_arg_int_ok(help, args,  'port')  # --port=PORT

  # cyber-dojo.sh does actual [up]
end

#==========================================================
# $ ./cyber-dojo start_point
#==========================================================

def start_point
  help = [
    '',
    "Use: #{me} start-point [COMMAND]",
    '',
    'Manage cyber-dojo start-points',
    '',
    'Commands:',
    minitab + 'create         Creates a new start-point',
    minitab + 'rm             Removes a start-point',
    minitab + 'latest         Updates docker images named inside a start-point',
    minitab + 'ls             Lists the names of all start-points',
    minitab + 'inspect        Displays details of a start-point',
    minitab + 'pull           Pulls all the docker images named inside a start-point',
    '',
    "Run '#{me} start-point COMMAND --help' for more information on a command",
  ]

  if [nil,'--help'].include? ARGV[1]
    show help
    exit succeeded
  end

  case ARGV[1]
    when 'create'  then start_point_create
    when 'rm'      then start_point_rm
    when 'latest'  then start_point_latest
    when 'ls'      then start_point_ls
    when 'inspect' then start_point_inspect
    when 'pull'    then start_point_pull
    else begin
      STDERR.puts "FAILED: unknown argument [#{ARGV[1]}]"
      exit(failed)
    end
  end
end

# - - - - - - - - - - - - - - -

def volume_exists?(name)
  # careful to match whole string
  start_of_line = '^'
  end_of_line = '$'
  pattern = "#{start_of_line}#{name}#{end_of_line}"
  run("docker volume ls --quiet | grep '#{pattern}'").include? name
end

def cyber_dojo_inspect(vol)
  info = run("docker volume inspect #{vol}")
  JSON.parse(info)[0]
end

def cyber_dojo_volume?(vol)
  labels = cyber_dojo_inspect(vol)['Labels'] || []
  labels.include? 'cyber-dojo-start-point'
end

def cyber_dojo_label(vol)
  cyber_dojo_inspect(vol)['Labels']['cyber-dojo-start-point']
end

def cyber_dojo_data_manifest(vol)
  command = quoted "cat /data/setup.json"
  JSON.parse(run "docker run --rm -v #{vol}:/data #{cyber_dojo_commander} sh -c #{command}")
end

def cyber_dojo_type(vol)
  cyber_dojo_data_manifest(vol)['type']
end

#==========================================================
# $ ./cyber-dojo start-point create
#==========================================================

def start_point_create
  help = [
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
  knowns = ['git','dir']
  unknown = args.select do |argv|
    knowns.none? { |known| argv.start_with?('--' + known + '=') }
  end
  unless unknown == []
    unknown.each { |arg| STDERR.puts "FAILED: unknown argument [#{arg.split('=')[0]}]" }
    exit failed
  end

  # required known arguments
  url = get_arg('--git', args)
  dir = get_arg('--dir', args)
  if url && dir
    STDERR.puts 'FAILED: specify --git=... OR --dir=... but not both'
    exit failed
  end
  # [cyber-dojo] does actual [start-point create NAME --dir=DIR]
  # [cyber-dojo.sh] does actual [start-point create NAME --git=URL]
end

# - - - - - - - - - - - - - - -

def exit_unless_is_cyber_dojo_volume(vol, command)
  if !volume_exists? vol
    STDERR.puts "FAILED: #{vol} does not exist."
    exit failed
  end

  unless cyber_dojo_volume? vol
    STDERR.puts "FAILED: #{vol} is not a cyber-dojo start-point."
    exit failed
  end
end

#==========================================================
# $ ./cyber-dojo start-point ls
#==========================================================

def start_point_ls
  help = [
    '',
    "Use: #{me} start-point [OPTIONS] ls",
    '',
    'Lists the names of all cyber-dojo start-points',
    '',
    minitab + '--quiet     Only display start-point names'
  ]

  if ARGV[2] == '--help'
    show help
    exit succeeded
  end

  # As of docker 1.12.0 there is no [--filter label=LABEL]
  # option on the [docker volume ls] command.
  # So I have to inspect all volumes.
  # Could be slow for lots of volumes.

  names = run("docker volume ls --quiet").split
  names = names.select{ |name| cyber_dojo_volume?(name) }

  if ARGV[2] == '--quiet'
    names.each { |name| puts name }
  else

    unless ARGV[2].nil?
      STDERR.puts "FAILED: unknown argument [#{ARGV[2]}]"
      exit failed
    end

    types = names.map { |name| cyber_dojo_type(name)  }
    urls  = names.map { |name| cyber_dojo_label(name) }

    headings = { :name => 'NAME', :type => 'TYPE', :url => 'SRC' }

    gap = 3
    max_name = ([headings[:name]] + names).max_by(&:length).length + gap
    max_type = ([headings[:type]] + types).max_by(&:length).length + gap
    max_url  = ([headings[:url ]] + urls ).max_by(&:length).length + gap

    spacer = lambda { |max,s| s + (space * (max - s.length)) }

    name = spacer.call(max_name, headings[:name])
    type = spacer.call(max_type, headings[:type])
    url  = spacer.call(max_url , headings[:url ])
    unless names.empty?
      puts name + type + url
    end
    names.length.times do |n|
      name = spacer.call(max_name, names[n])
      type = spacer.call(max_type, types[n])
      url  = spacer.call(max_url ,  urls[n])
      puts name + type + url
    end
  end
end

#==========================================================
# $ ./cyber-dojo start-point inspect
#==========================================================

def start_point_inspect
  help = [
    '',
    "Use: #{me} start-point inspect NAME",
    '',
    'Displays details of the named start-point',
  ]

  vol = ARGV[2]
  if [nil,'--help'].include? vol
    show help
    exit succeeded
  end

  exit_unless_is_cyber_dojo_volume(vol, 'inspect')

  unless ARGV[3].nil?
    STDERR.puts "FAILED: unknown argument [#{ARGV[3]}]"
    exit failed
  end

  command =
  [
    'docker run',
    '--rm',
    "--user=root",
    "--volume=#{vol}:/data:#{read_only}",
    '--volume=/var/run/docker.sock:/var/run/docker.sock',
    "#{cyber_dojo_commander}",
    "sh -c './start_point_inspect.rb /data'"
  ].join(space=' ')
  print run(command)
end

#==========================================================
# $ ./cyber-dojo start-point rm
#==========================================================

def start_point_rm
  # Allow deletion of a default volume.
  # This allows you to create custom default volumes.
  help = [
    '',
    "Use: #{me} start-point rm NAME",
    '',
    "Removes a start-point created with the [#{me} start-point create] command"
  ]

  vol = ARGV[2]
  if [nil,'help'].include? vol
    show help
    exit succeeded
  end

  exit_unless_is_cyber_dojo_volume(vol, 'rm')

  unless ARGV[3].nil?
    puts "FAILED: unknown argument [#{ARGV[3]}]"
    exit failed
  end

  run "docker volume rm #{vol} 2>&1 /dev/null"
  if $exit_status != 0
    puts "FAILED cannot remove start-point #{vol}. Is it in use?"
    exit failed
  end

end

#==========================================================
# $ ./cyber-dojo start-point pull
#==========================================================
#
def start_point_pull
  help = [
    '',
    "Use: #{me} start-point pull NAME",
    '',
    'Pulls all the docker images inside the named start-point'
  ]

  vol = ARGV[2]
  if [nil,'--help'].include? vol
    show help
    exit succeeded
  end

  exit_unless_is_cyber_dojo_volume(vol, 'pull')

  unless ARGV[3].nil?
    STDERR.puts "FAILED: unknown argument [#{ARGV[3]}]"
    exit failed
  end

  command =
  [
    'docker run',
    '--rm',
    '--tty',
    "--user=root",
    "--volume=#{vol}:/data:#{read_only}",
    '--volume=/var/run/docker.sock:/var/run/docker.sock',
    "#{cyber_dojo_commander}",
    "sh -c './start_point_pull.rb /data'"
  ].join(space=' ')

  system(command)
end

#==========================================================
# $ ./cyber-dojo start-point latest
#==========================================================
#
def start_point_latest
  help = [
    '',
    "Use: #{me} start-point latest NAME",
    '',
    'Re-pulls already pulled docker images inside the named start-point'
  ]

  vol = ARGV[2]
  if [nil,'--help'].include? vol
    show help
    exit succeeded
  end

  exit_unless_is_cyber_dojo_volume(vol, 'pull')

  unless ARGV[3].nil?
    STDERR.puts "FAILED: unknown argument [#{ARGV[3]}]"
    exit failed
  end

  command =
  [
    'docker run',
    '--rm',
    '--tty',
    "--user=root",
    "--volume=#{vol}:/data:#{read_only}",
    '--volume=/var/run/docker.sock:/var/run/docker.sock',
    "#{cyber_dojo_commander}",
    "sh -c './start_point_latest.rb /data'"
  ].join(space=' ')

  system(command)
end

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

def help
  puts [
    '',
    "Use: #{me} [--debug] COMMAND",
    "     #{me} --help",
    '',
    'Commands:',
    tab + 'clean        Removes old images/volumes/containers',
    tab + 'down         Brings down the server',
    tab + 'logs         Prints the logs from the server',
    tab + 'sh           Shells into the server',
    tab + 'up           Brings up the server',
    tab + 'update       Updates the server to the latest images',
    tab + 'start-point  Manages cyber-dojo start-points',
    '',
    "Run '#{me} COMMAND --help' for more information on a command."
  ].join("\n") + "\n"
end

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

case ARGV[0]
  when nil             then help
  when '--help'        then help
  when 'clean'         then clean
  when 'down'          then down
  when 'logs'          then logs
  when 'sh'            then sh
  when 'up'            then up
  when 'update'        then update
  when 'update-images' then update_images
  when 'start-point'   then start_point
  else
    STDERR.puts "FAILED: unknown argument [#{ARGV[0]}]"
    exit failed
end

exit 0
