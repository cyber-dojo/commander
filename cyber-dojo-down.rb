
def cyber_dojo_down
  help = [
    '',
    "Use: #{me} down",
    '',
    "Stops and removes docker containers created with 'up'",
  ]

  if ARGV[1] == '-h' || ARGV[1] == '--help'
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
    'CYBER_DOJO_ENV_ROOT' => ENV['CYBER_DOJO_ENV_ROOT'],
    'CYBER_DOJO_START_POINTS_CUSTOM_IMAGE'    => default_custom,
    'CYBER_DOJO_START_POINTS_EXERCISES_IMAGE' => default_exercises,
    'CYBER_DOJO_START_POINTS_LANGUAGES_IMAGE' => default_languages,
    'CYBER_DOJO_NGINX_PORT' => default_port
  }
  my_dir = File.dirname(__FILE__)
  docker_compose_cmd = "docker-compose --file=#{my_dir}/docker-compose.yml"
  system(env_vars, "#{docker_compose_cmd} down")

end
