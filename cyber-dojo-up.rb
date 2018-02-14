
def cyber_dojo_up
  help = [
    '',
    "Use: #{me} up [OPTIONS]",
    '',
    'Creates and starts the cyber-dojo server using named/default start-points',
    '',
    minitab + '--languages=START-POINTS  Specify the languages start-points.',
    minitab + "                          Defaults to the start-points named 'languages' created from",
    minitab + '                          https://github.com/cyber-dojo/start-points-languages.git',
    '',
    minitab + '--exercises=START-POINTS  Specify the exercises start-points.',
    minitab + "                          Defaults to the start-points named 'exercises' created from",
    minitab + '                          https://github.com/cyber-dojo/start-points-exercises.git',
    '',
    minitab + '--custom=START-POINTS     Specify the custom start-points.',
    minitab + "                          Defaults to the start-points named 'custom' created from",
    minitab + '                          https://github.com/cyber-dojo/start-points-custom.git',
    '',
    minitab + '--port=LISTEN-PORT        Specify port to listen on.',
    minitab + "                          Defaults to 80"
  ]

  if ARGV[1] == '--help'
    show help
    exit succeeded
  end

  # Unknown arguments?
  args = ARGV[1..-1]
  knowns = ['languages','exercises','custom','port']
  unknowns = args.select do |arg|
    knowns.none? { |known| arg.start_with?('--' + known + '=') }
  end
  unknowns.each do |unknown|
    arg = unknown.split('=')[0]
    STDERR.puts "FAILED: unknown argument [#{arg}]"
  end
  exit failed unless unknowns == []

  # Explicit start-points?
  exit failed unless up_arg_ok(help, args, 'languages')  # --languages=NAME
  exit failed unless up_arg_ok(help, args, 'exercises')  # --exercises=NAME
  exit failed unless up_arg_ok(help, args,    'custom')  # --custom=NAME
  exit failed unless up_arg_int_ok(help, args,  'port')  # --port=PORT

  languages = default_languages
  exercises = default_exercises
  custom = default_custom
  port = default_port

  args.each do |arg|
    name = arg.split('=')[0]
    value = arg.split('=')[1]
    languages = value if name == '--languages'
    exercises = value if name == '--exercises'
    custom    = value if name == '--custom'
    port      = value if name == '--port'
  end

  # Create default start-points if necessary
  github_cyber_dojo = 'https://github.com/cyber-dojo'
  if languages == default_languages && !volume_exists?(default_languages)
    url='https://raw.githubusercontent.com/cyber-dojo/start-points-languages/master/languages_list'
    url_list = run("curl -s #{url}").split
    STDOUT.puts "Creating start-point #{default_languages} from #{url}"
    cyber_dojo_start_point_create_list(default_languages, url_list)
  end
  if exercises == default_exercises && !volume_exists?(default_exercises)
    url = "#{github_cyber_dojo}/start-points-exercises.git"
    STDOUT.puts "Creating start-point #{default_exercises} from #{url}"
    cyber_dojo_start_point_create_list(default_exercises, [ url ])
  end
  if custom == default_custom && !volume_exists?(default_custom)
    url = "#{github_cyber_dojo}/start-points-custom.git"
    STDOUT.puts "Creating start-point #{default_custom} from #{url}"
    cyber_dojo_start_point_create_list(default_custom, [ url ])
  end

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
  %w( grafana nginx web zipper ).each do |name|
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

  # Bring up server with volumes
  STDOUT.puts "Using --languages=#{languages}"
  STDOUT.puts "Using --exercises=#{exercises}"
  STDOUT.puts "Using --custom=#{custom}"
  STDOUT.puts "Using --port=#{port}"
  env_vars = {
    'CYBER_DOJO_ENV_ROOT' => env_root,
    'CYBER_DOJO_START_POINT_LANGUAGES' => languages,
    'CYBER_DOJO_START_POINT_EXERCISES' => exercises,
    'CYBER_DOJO_START_POINT_CUSTOM' => custom,
    'CYBER_DOJO_NGINX_PORT' => port,
    'CYBER_DOJO_KATAS_DATA_CONTAINER' => 'cyber-dojo-katas-DATA-CONTAINER'
  }
  my_dir = File.dirname(__FILE__)
  docker_compose_cmd = "docker-compose --file=#{my_dir}/docker-compose.yml"
  # It seems a successful [docker-compose up] writes to stderr !?
  # See https://github.com/docker/compose/issues/3267
  system(env_vars, "#{docker_compose_cmd} up -d 2>&1")
end

# - - - - - - - - - - - - - - - - - - - - - - - - -

def up_arg_int_ok(help, args, name)
  int_value = get_arg("--#{name}", args)
  if int_value.nil?
    return true
  end

  if int_value == ''
    STDERR.puts "FAILED: missing argument value --#{name}=[???]"
    return false
  end

  # TODO: validate that it's an int?

  return true
end

# - - - - - - - - - - - - - - - - - - - - - - - - -

def up_arg_ok(help, args, name)
  vol = get_arg("--#{name}", args)
  if vol.nil? || vol == name # handled in cyber-dojo.sh
    return true
  end

  if vol == ''
    STDERR.puts "FAILED: missing argument value --#{name}=[???]"
    return false
  end

  unless volume_exists?(vol)
    STDERR.puts "FAILED: start-point #{vol} does not exist"
    return false
  end

  type = cyber_dojo_type(vol)
  if type != name
    STDERR.puts "FAILED: #{vol} is not a #{name} start-point (it's type from setup.json is #{type})"
    return false
  end

  return true
end
