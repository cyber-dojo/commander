
def cyber_dojo_server_down
  exit_success_if_down_help
  exit_failure_if_down_unknown_arguments
  # A successful [docker-compose ... down] writes to stderr !?
  # See https://github.com/docker/compose/issues/3267
  system(down_env_vars, "#{docker_compose_cmd} down 2>&1")
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
  vars = {
    'CYBER_DOJO_CUSTOM'    => dot_env['CYBER_DOJO_CUSTOM'],
    'CYBER_DOJO_EXERCISES' => dot_env['CYBER_DOJO_EXERCISES'],
    'CYBER_DOJO_LANGUAGES' => dot_env['CYBER_DOJO_LANGUAGES'],
    'CYBER_DOJO_PORT'      => dot_env['CYBER_DOJO_PORT'],
    'CYBER_DOJO_ENV_ROOT' => ENV['CYBER_DOJO_ENV_ROOT']
  }
  service_names.each do |name|
    key = "CYBER_DOJO_#{name.upcase}_TAG"
    vars[key] = 'avoid-warning-about-tag-not-being-set'
  end
  vars
end
