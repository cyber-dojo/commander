
def cyber_dojo_start_points_inspect
  help = [
    '',
    "Use: #{me} start-points inspect IMAGE_NAME",
    '',
    'Displays details of the named start-points image',
  ]

  image_name = ARGV[2]
  if [nil,'-h','--help'].include?(image_name)
    show help
    exit succeeded
  end

  exit_unless_start_point_image(image_name)

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
    "--user=root",
    # "--volume=#{vol}:/data:#{read_only}",
    '--volume=/var/run/docker.sock:/var/run/docker.sock',
    "#{cyber_dojo_commander}",
    "sh -c './start_point_inspect.rb /data'"
  ].join(space=' ')
  print run(command)
end
