
def cyber_dojo_start_point_pull
  help = [
    '',
    "Use: #{me} start-point pull IMAGE_NAME",
    '',
    'Pulls all the docker images inside the named start-point image'
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
    '--tty',
    "--user=root",
    # "--volume=#{vol}:/data:#{read_only}",
    '--volume=/var/run/docker.sock:/var/run/docker.sock',
    "#{cyber_dojo_commander}",
    "sh -c './start_point_pull.rb /data'"
  ].join(space=' ')

  system(command)
end
