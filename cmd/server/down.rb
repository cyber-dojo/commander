
def cyber_dojo_server_down
  exit_success_if_down_help
  exit_failure_if_down_unknown_arguments

  if docker_swarm?
    system("docker stack down cyber-dojo")
  else
    # A successful [docker-compose ... down] writes to stderr !?
    # See https://github.com/docker/compose/issues/3267
    system(down_env_vars, "docker-compose #{docker_yml_files} down --remove-orphans 2>&1")
  end
end

# - - - - - - - - - - - - - - - - - - - - - - - - -

def exit_success_if_down_help
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
  dot_env.merge({ 'ENV_ROOT' => env_root })
end
