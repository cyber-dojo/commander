
def cyber_dojo_start_point_inspect
  exit_success_if_show_start_point_inspect_help
  exit_failure_if_start_point_inspect_unknown_arguments
  name = ARGV[2]
  puts cyber_dojo_start_point_inspection(name)
end

# - - - - - - - - - - - - - - - - - - - - - - - -

def cyber_dojo_start_point_inspection(name)
  command =
  [
    'docker run',
    '--rm',
    '--interactive',
    name,
    "sh -c 'ruby /app/repos/inspect.rb'"
  ].join(' ')
  run(command)
end

# - - - - - - - - - - - - - - - - - - - - - - - -

def exit_success_if_show_start_point_inspect_help
  help = [
    '',
    "Use: #{me} start-point inspect NAME",
    '',
    'Prints the display_name, image_name, sha, and url of each entry in the named start-point',
  ]
  name = ARGV[2]
  if [nil,'-h','--help'].include?(name)
    show help
    exit succeeded
  end
end

# - - - - - - - - - - - - - - - - - - - - - - - -

def exit_failure_if_start_point_inspect_unknown_arguments
  name = ARGV[2]
  exit_unless_start_point_image(name)
  ARGV[3..-1].each do |arg|
    STDERR.puts "FAILED: unknown argument [#{arg}]"
  end
  unless ARGV[3].nil?
    exit failed
  end
end
