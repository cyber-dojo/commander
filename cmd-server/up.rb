
def cyber_dojo_server_up
  exit_success_if_show_up_help
  exit_failure_if_up_unknown_arguments

  # Process arguments
     custom = default_custom
  exercises = default_exercises
  languages = default_languages
       port = default_port

  args = ARGV[1..-1]
  args.each do |arg|
    name  = arg.split('=')[0]
    value = arg.split('=')[1]
    if value.nil?
      STDERR.puts "FAILED: missing argument value #{name}=[???]"
      exit failed
    end
       custom = value if name == '--custom'
    exercises = value if name == '--exercises'
    languages = value if name == '--languages'
         port = value if name == '--port'
  end

  # Ensure all docker images named in start-points
  # exists (there is no image-pull on-demand).
  check_cyber_dojo_start_point_exists(   'custom',    custom)
  check_cyber_dojo_start_point_exists('exercises', exercises)
  check_cyber_dojo_start_point_exists('languages', languages)

  sh_root = ENV['CYBER_DOJO_SH_ROOT']
  # Write .env files to where docker-compose.yml expects them to be
  unless File.exist?("#{sh_root}/grafana.env")
    puts 'WARNING: Using default grafana admin password.'
    puts 'To set your own password and remove this warning:'
    puts '   1. Create a file grafana.env with contents'
    puts '      GF_SECURITY_ADMIN_PASSWORD=mypassword'
    puts '      in the same directory as the cyber-dojo script.'
    puts '   2. Re-issue the command [cyberdojo up ...]'
  end

  env_root = ENV['CYBER_DOJO_ENV_ROOT']
  %w( grafana nginx web ).each do |name|
    from = "#{sh_root}/#{name}.env"
    to = "#{env_root}/#{name}.env"
    if File.exist?(from)
      puts "Using custom #{name}.env"
      content = IO.read(from)
      File.open(to, 'w') { |file| file.write(content) }
    else
      puts "Using default #{name}.env"
    end
  end

  # Bring up server
  STDOUT.puts "Using --custom=#{custom}"
  STDOUT.puts "Using --exercises=#{exercises}"
  STDOUT.puts "Using --languages=#{languages}"
  STDOUT.puts "Using --port=#{port}"
  env_vars = {
    'CYBER_DOJO_ENV_ROOT' => env_root,
    'CYBER_DOJO_START_POINT_CUSTOM_IMAGE'    => custom,
    'CYBER_DOJO_START_POINT_EXERCISES_IMAGE' => exercises,
    'CYBER_DOJO_START_POINT_LANGUAGES_IMAGE' => languages,
    'CYBER_DOJO_NGINX_PORT' => port
  }
  my_dir = File.dirname(__FILE__)
  docker_compose_cmd = "docker-compose --file=#{my_dir}/../docker-compose.yml"
  # It seems a successful [docker-compose up] writes to stderr !?
  # See https://github.com/docker/compose/issues/3267
  system(env_vars, "#{docker_compose_cmd} up -d 2>&1")
end

# - - - - - - - - - - - - - - - - - - - - - - - - -

def exit_success_if_show_up_help
  help = [
    '',
    "Use: #{me} up [OPTIONS]",
    '',
    'Creates and starts a cyber-dojo server using named/default start-points.',
    '',
    'Options:',
    minitab + '--custom=NAME       Specify the custom start-point name.',
    minitab + '--exercises=NAME    Specify the exercises start-point name.',
    minitab + '--languages=NAME    Specify the languages start-point name.',
    minitab + '--port=PORT         Specify the port number.',
    '',
    'Defaults:',
    minitab + '--custom=cyberdojo/custom',
    minitab + '--exercises=cyberdojo/exercises',
    minitab + '--languages=cyberdojo/languages-common',
    minitab + '--port=80',
    '',
    'Defaults were created using:',
    minitab + '$ ./cyber-dojo start-point create \\',
    minitab + '    cyberdojo/custom \\',
    minitab + '      --custom \\',
    minitab + '        https://github.com/cyber-dojo/custom.git',
    '',
    minitab + '$ ./cyber-dojo start-point create \\',
    minitab + '    cyberdojo/exercises \\',
    minitab + '      --exercises \\',
    minitab + '        https://github.com/cyber-dojo/exercises.git',
    '',
    minitab + '$ ./cyber-dojo start-point create \\',
    minitab + '    cyberdojo/languages-common \\',
    minitab + '      --languages \\',
    minitab + '        $(curl --silent https://github.com/cyber-dojo/languages/master/url_list/common)',
  ]
  if ['-h','--help'].include?(ARGV[1])
    show help
    exit succeeded
  end
end

# - - - - - - - - - - - - - - - - - - - - - - - - -

def exit_failure_if_up_unknown_arguments
  args = ARGV[1..-1]
  knowns = %w( custom exercises languages port )
  unknowns = args.select do |arg|
    knowns.none? { |known| arg.start_with?('--' + known + '=') }
  end
  unknowns.each do |unknown|
    arg = unknown.split('=')[0]
    STDERR.puts "FAILED: unknown argument [#{arg}]"
  end
  exit failed unless unknowns == []
end

# - - - - - - - - - - - - - - - - - - - - - - - - -

def check_cyber_dojo_start_point_exists(type, image_name)
  unless image_exists?(image_name)
    STDERR.puts "FAILED: cannot find a start-point called #{image_name}"
    exit failed
  end
  unless start_point_image?(image_name)
    STDERR.puts "FAILED: #{image_name} was not created using [cyber-dojo start-point create]"
    exit failed
  end
  image_type = start_point_type(image_name)
  unless image_type == type
    STDERR.puts "FAILED: the type of #{image_name} is #{image_type} (not #{type})"
    exit failed
  end

=begin
  command =
  [
    'docker run',
    '--rm',
    '--tty',
    "--user=root",
    "--volume=#{vol}:/data:#{read_only}",
    '--volume=/var/run/docker.sock:/var/run/docker.sock',
    "#{cyber_dojo_commander}",
    "sh -c './start_point_exist.rb /data'"
  ].join(space=' ')
  STDOUT.puts "checking images in start-point [#{vol}] all exist..."
  system(command)
=end
end
