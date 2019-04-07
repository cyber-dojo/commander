
def cyber_dojo_server_down
  exit_success_if_show_down_help
  exit_failure_if_down_unknown_arguments
  my_dir = File.dirname(__FILE__)
  docker_compose_cmd = "docker-compose --file=#{my_dir}/../../docker-compose.yml"
  system(down_env_vars, "#{docker_compose_cmd} down")
end

# - - - - - - - - - - - - - - - - - - - - - - - - -

def exit_success_if_show_down_help
  help = [
    '',
    "Use: #{me} down",
    '',
    "Stops and removes docker containers created with 'up'",
  ]
  if ['-h','--help'].include?(ARGV[1])
    show help
    exit succeeded
  end
end

# - - - - - - - - - - - - - - - - - - - - - - - - -

def exit_failure_if_down_unknown_arguments
  args = ARGV[1..-1]
  args.each do |arg|
    STDERR.puts "FAILED: unknown argument [#{arg}]"
  end
  unless ARGV[1].nil?
    exit failed
  end
end

# - - - - - - - - - - - - - - - - - - - - - - - - -

def down_env_vars
  {
    'CYBER_DOJO_ENV_ROOT' => ENV['CYBER_DOJO_ENV_ROOT'],
    'CYBER_DOJO_START_POINT_CUSTOM_IMAGE'    => default_custom,
    'CYBER_DOJO_START_POINT_EXERCISES_IMAGE' => default_exercises,
    'CYBER_DOJO_START_POINT_LANGUAGES_IMAGE' => default_languages,
    'CYBER_DOJO_NGINX_PORT' => default_port
  }
end
