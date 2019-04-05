
def cyber_dojo_start_point_inspect
  help = [
    '',
    "Use: #{me} start-point inspect NAME",
    '',
    'Displays details of the named start-point',
  ]

  name = ARGV[2]
  if [nil,'-h','--help'].include?(name)
    show help
    exit succeeded
  end

  exit_unless_start_point_image(name)

  ARGV[3..-1].each do |arg|
    STDERR.puts "FAILED: unknown argument [#{arg}]"
  end
  unless ARGV[3].nil?
    exit failed
  end

  command =
  [
    'docker run',
    '--rm',
    '--interactive',
    name,
    "sh -c 'ruby /app/repos/inspect.rb'"
  ].join(' ')
  puts run(command)
end
