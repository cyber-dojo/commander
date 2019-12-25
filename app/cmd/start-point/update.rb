
require_relative 'exit_unless_start_point_image'

def cyber_dojo_start_point_update
  exit_success_if_show_start_point_update_help
  exit_failure_if_start_point_update_unknown_arguments
  name = ARGV[2]
  exit_unless_start_point_image(name)
  get_manifests_image_names(name).each do |image_name|
    STDOUT.puts ">>pulling #{image_name}"
    system("docker pull #{image_name}:latest")
  end
end

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

def exit_success_if_show_start_point_update_help
  help = [
    '',
    "Use: #{me} start-point update NAME",
    '',
    'Updates all the docker images inside the named start-point'
  ]
  name = ARGV[2]
  if [nil,'-h','--help'].include?(name)
    show help
    exit succeeded
  end
end

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

def exit_failure_if_start_point_update_unknown_arguments
  ARGV[3..-1].each do |arg|
    STDERR.puts "ERROR: unknown argument [#{arg}]"
  end
  unless ARGV[3].nil?
    exit failed
  end
end
