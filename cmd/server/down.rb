
def cyber_dojo_server_down
  exit_success_if_show_down_help
  exit_failure_if_down_unknown_arguments
  my_dir = File.dirname(__FILE__)
  docker_compose_cmd = [
    'docker-compose',
    "--file=#{my_dir}/../../docker-compose.yml",
    "--file=#{my_dir}/../../docker-compose.images.yml"
  ].join(' ')
  # It seems a successful [docker-compose ... down] writes to stderr !?
  # See https://github.com/docker/compose/issues/3267
  system(down_env_vars, "#{docker_compose_cmd} down 2>&1")
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
    'CYBER_DOJO_CUSTOM'    => custom_image_name,
    'CYBER_DOJO_EXERCISES' => exercises_image_name,
    'CYBER_DOJO_LANGUAGES' => languages_image_name,
    'CYBER_DOJO_NGINX_PORT' => port_number
  }
end
