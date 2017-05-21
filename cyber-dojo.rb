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
  if !volume_exists? vol
    STDERR.puts "FAILED: #{vol} does not exist."
    exit failed
  end

  unless cyber_dojo_volume? vol
    STDERR.puts "FAILED: #{vol} is not a cyber-dojo start-point."
    exit failed
  end
end

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

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
  when 'update-images' then cyber_dojo_update_images
  else
    STDERR.puts "FAILED: unknown argument [#{ARGV[0]}]"
    exit failed
end

exit 0
