#!/usr/bin/env ruby

# Called from cyber-dojo-inner

require 'json'
require 'tempfile'

require_relative 'help'
require_relative 'start-point/all'
require_relative 'server/all'
require_relative 'service/all'

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

def space; ' '; end

def tab; space * 4; end

def minitab; space * 2; end

def show(lines); lines.each { |line| puts line }; print "\n"; end

def quoted(s); '"' + s + '"'; end

def env_root; '/app/env_files'; end

# - - - - - - - - - - - - - - - - - - - - - - - - -

def dot_env
  $dot_env ||= begin
    src = `docker run --rm cyberdojo/versioner:latest ruby /app/src/echo_env_vars.rb`
    env_file_to_h(src)
  end
end

def env_file_to_h(src)
  lines = src.lines.reject do |line|
    line.start_with?('#') || line.strip.empty?
  end
  lines.map{ |line| line.split('=').map(&:strip) }.to_h
end

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
  # eg name: --custom
  #    argv: --custom=IMAGE
  #    ====> returns IMAGE
  args = argv.select{ |arg| arg.start_with?(name + '=')}.map{ |arg| arg.split('=')[1] || '' }
  args.size == 1 ? args[0] : nil
end

# - - - - - - - - - - - - - - - - - - - - - - - - -

def exit_unless_start_point_image(image_name)
  unless image_exists?(image_name)
    STDERR.puts "ERROR: #{image_name} does not exist."
    exit failed
  end
  unless start_point_image?(image_name)
    STDERR.puts "ERROR: #{image_name} is not a cyber-dojo start-point image."
    exit failed
  end
end

def image_exists?(image_name)
  cmd  = 'docker image ls'
  cmd += " --filter=reference=#{image_name}"
  cmd += " --format '{{.Repository}}:{{.Tag}}'"
  run(cmd).split != []
end

def start_point_image?(image_name)
  # [docker image ls] lists image names with their tag (eg :latest)
  # but image_name may be tagless and defaulting to :latest
  cmd  = 'docker image ls'
  cmd += " --filter 'label=org.cyber-dojo.start-point'"
  cmd += " --format '{{.Repository}}:{{.Tag}}'"
  names = run(cmd).split
  names.include?(image_name) || names.include?(image_name + ':latest')
end

def start_point_type(image_name)
  command = "docker inspect --format='{{json .ContainerConfig.Labels}}' #{image_name}"
  labels = run(command)
  # returns eg {"maintainer":"jon@jaggersoft.com","org.cyber-dojo.start-points":"custom"}
  json = JSON.parse(labels)
  json['org.cyber-dojo.start-point']
end

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

case ARGV[0]
  when nil            then cyber_dojo_help
  when '-h'           then cyber_dojo_help
  when '--help'       then cyber_dojo_help
  when 'clean'        then cyber_dojo_server_clean
  when 'down'         then cyber_dojo_server_down
  when 'logs'         then cyber_dojo_service_logs
  when 'start-point'  then cyber_dojo_start_point
  when 'up'           then cyber_dojo_server_up
  when 'update'       then cyber_dojo_server_update
  when 'version'      then cyber_dojo_server_version
  else
    STDERR.puts "ERROR: unknown argument [#{ARGV[0]}]"
    exit failed
end

exit 0
