#!/usr/bin/env ruby

# Called from cyber-dojo.sh
# Returns non-zero to indicate cyber-dojo.sh should not proceed.

require 'json'
require 'tempfile'

require_relative 'cyber-dojo-clean'
require_relative 'cyber-dojo-down'
require_relative 'cyber-dojo-help'
require_relative 'cyber-dojo-logs'
require_relative 'cyber-dojo-sh'
require_relative 'cyber-dojo-start-point'
require_relative 'cyber-dojo-up'
require_relative 'cyber-dojo-update'

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

# - - - - - - - - - - - - - - - - - - - - - - - - -

def default_languages; 'languages'; end
def default_exercises; 'exercises'; end
def default_custom; 'custom'; end
def default_port; '80'; end

# - - - - - - - - - - - - - - - - - - - - - - - - -

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

# - - - - - - - - - - - - - - - - - - - - - - - - -

def get_arg(name, argv)
  # eg name: --git
  #    argv: --git=URL
  #    ====> returns URL
  args = argv.select{ |arg| arg.start_with?(name + '=')}.map{ |arg| arg.split('=')[1] || '' }
  args.size == 1 ? args[0] : nil
end

# - - - - - - - - - - - - - - - - - - - - - - - - -

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

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

def exit_unless_is_cyber_dojo_volume(vol, command)
  unless volume_exists? vol
    STDERR.puts "FAILED: #{vol} does not exist."
    exit failed
  end

  unless cyber_dojo_volume? vol
    STDERR.puts "FAILED: #{vol} is not a cyber-dojo start-point."
    exit failed
  end
end

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

def one_time_creation_of_katas_data_volume
  # The katas data-volume is not created as a named volume because
  # it predates that feature.
  # A previous version of this script detected if /var/www/cyber-dojo/katas
  # existed on the host in which case it assumed an old cyber-dojo server
  # was being upgraded and automatically copied it into the new volume.
  # It doesn't do that any more. If you want to upgrade an older server
  # have a look at old-notes/copy_katas_into_data_container.sh in
  # https://github.com/cyber-dojo/cyber-dojo
  katas_data_container = 'cyber-dojo-katas-DATA-CONTAINER'
  command = "docker ps --all | grep -s #{katas_data_container} > /dev/null"
  run(command)
  if $exit_status != 0
    context_dir = '.'
    command = 'cp Dockerignore.katas .dockerignore'
    run(command)

    tag = 'cyberdojo/katas'
    # create a katas volume - it is mounted into the web container
    # using a volumes_from in docker-compose.yml
    command = [
      'docker build',
        '--build-arg=CYBER_DOJO_KATAS_ROOT=/usr/src/cyber-dojo/katas',
        "--tag=#{tag}",
        '--file=Dockerfile.katas',
        "#{context_dir} > /dev/null"
    ].join(space)
    run(command)

    run('rm .dockerignore')
    command = [
      'docker create',
        "--name #{katas_data_container}",
        tag,
        "echo 'cdfKatasDC' > /dev/null"
      ].join(space)
    run(command)
  end
end

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

one_time_creation_of_katas_data_volume

case ARGV[0]
  when nil             then cyber_dojo_help
  when '--help'        then cyber_dojo_help
  when 'clean'         then cyber_dojo_clean
  when 'down'          then cyber_dojo_down
  when 'logs'          then cyber_dojo_logs
  when 'sh'            then cyber_dojo_sh
  when 'start-point'   then cyber_dojo_start_point
  when 'up'            then cyber_dojo_up
  when 'update'        then cyber_dojo_update
  else
    STDERR.puts "FAILED: unknown argument [#{ARGV[0]}]"
    exit failed
end

exit 0
