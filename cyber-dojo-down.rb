
def cyber_dojo_down
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

  my_dir = File.dirname(__FILE__)
  docker_compose_cmd = "docker-compose --file=#{my_dir}/docker-compose.yml"
  command = "#{docker_compose_cmd} down"
  system(command)
end
