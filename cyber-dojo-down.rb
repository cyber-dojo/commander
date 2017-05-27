
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

  ARGV[1..-1].each do |arg|
    STDERR.puts "FAILED: unknown argument [#{arg}]"
  end
  unless ARGV[1].nil?
    exit failed
  end

  env_vars = {
    'CYBER_DOJO_START_POINT_LANGUAGES' => default_languages,
    'CYBER_DOJO_START_POINT_EXERCISES' => default_exercises,
    'CYBER_DOJO_START_POINT_CUSTOM' => default_custom,
    'CYBER_DOJO_NGINX_PORT' => default_port,
    'CYBER_DOJO_KATAS_DATA_CONTAINER' => 'cyber-dojo-katas-DATA-CONTAINER'
  }
  my_dir = my_dir = File.dirname(__FILE__)
  docker_compose_cmd = "docker-compose --file=#{my_dir}/docker-compose.yml"
  system(env_vars, "#{docker_compose_cmd} down")

end
