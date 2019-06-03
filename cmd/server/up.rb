
def cyber_dojo_server_up
  exit_success_if_up_help
  exit_failure_if_up_unknown_arguments

  custom = start_point_custom
  exercises = start_point_exercises
  languages = start_point_languages

  exit_failure_unless_start_point_exists(   'custom',    custom)
  exit_failure_unless_start_point_exists('exercises', exercises)
  exit_failure_unless_start_point_exists('languages', languages)

  pull_all_images_named_in(custom)
  pull_all_images_named_in(languages)

  env_root = write_env_files

  port = ENV['CYBER_DOJO_PORT'] || port_number

  env_vars = {
    'CYBER_DOJO_ENV_ROOT'   => env_root,
    'CYBER_DOJO_NGINX_PORT' => port,
    'CYBER_DOJO_CUSTOM'    => custom,
    'CYBER_DOJO_EXERCISES' => exercises,
    'CYBER_DOJO_LANGUAGES' => languages,
  }
  add_image_tag_variables(env_vars)

  STDOUT.puts "Using --custom=#{custom}"
  STDOUT.puts "Using --exercises=#{exercises}"
  STDOUT.puts "Using --languages=#{languages}"
  STDOUT.puts "Using --port=#{port}"

  # A successful [docker-compose ... up] writes to stderr !?
  # See https://github.com/docker/compose/issues/3267
  system(env_vars, "#{docker_compose_cmd} up -d 2>&1")
end

# - - - - - - - - - - - - - - - - - - - - - - - - -

def start_point_custom
  custom = custom_image_name
  start_point_command_line_options.each do |name,value|
    custom = value if name == '--custom'
  end
  ENV['CYBER_DOJO_CUSTOM'] || custom
end

# - - - - - - - - - - - - - - - - - - - - - - - - -

def start_point_exercises
  exercises = exercises_image_name
  start_point_command_line_options.each do |name,value|
    exercises = value if name == '--exercises'
  end
  ENV['CYBER_DOJO_EXERCISES'] || exercises
end

# - - - - - - - - - - - - - - - - - - - - - - - - -

def start_point_languages
  languages = languages_image_name
  start_point_command_line_options.each do |name,value|
    languages = value if name == '--languages'
  end
  ENV['CYBER_DOJO_LANGUAGES'] || languages
end

# - - - - - - - - - - - - - - - - - - - - - - - - -

def start_point_command_line_options
  ARGV[1..-1].each do |arg|
    name,value = arg.split('=',2)
    if value.nil? || value.empty?
     STDERR.puts "ERROR: missing argument value #{name}=[???]"
     exit failed
   else
     yield name,value
   end
  end
end

# - - - - - - - - - - - - - - - - - - - - - - - - -

def write_env_files
  sh_root = ENV['CYBER_DOJO_SH_ROOT']
  unless File.exist?("#{sh_root}/grafana.env")
    puts 'WARNING: Using default grafana admin password.'
    puts 'To set your own password and remove this warning:'
    puts '   1. Create a file grafana.env with contents'
    puts '      GF_SECURITY_ADMIN_PASSWORD=mypassword'
    puts '      in the same directory as the cyber-dojo script.'
    puts '   2. Re-issue the command [cyberdojo up ...]'
  end
  # Write any .env files to where docker-compose.yml expects them
  env_root = ENV['CYBER_DOJO_ENV_ROOT']
  %w( grafana nginx web ).each do |name|
    from = "#{sh_root}/#{name}.env"
    if File.exist?(from)
      puts "Using custom #{name}.env"
      content = IO.read(from)
      to = "#{env_root}/#{name}.env"
      File.open(to, 'w') { |file| file.write(content) }
    else
      puts "Using default #{name}.env"
    end
  end
  env_root
end

# - - - - - - - - - - - - - - - - - - - - - - - - -

def add_image_tag_variables(env_vars)
  service_names.each do |service|
    name = service.upcase
    key = "CYBER_DOJO_#{name}_SHA"
    sha = dot_env[key]
    env_vars["CYBER_DOJO_#{name}_TAG"] = sha[0...7] # '5c95484'
  end
  env_vars
end

# - - - - - - - - - - - - - - - - - - - - - - - - -

def exit_success_if_up_help
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
    'Default start-points were created using:',
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
    minitab + '        $(curl --silent https://raw.githubusercontent.com/cyber-dojo/languages/master/url_list/common)',
  ]
  if ['-h','--help'].include?(ARGV[1])
    show help
    exit succeeded
  end
end

# - - - - - - - - - - - - - - - - - - - - - - - - -

def exit_failure_if_up_unknown_arguments
  args = ARGV[1..-1]
  knowns = %w( --custom --exercises --languages --port )
  unknowns = args.select do |arg|
    knowns.none? { |known| arg.split('=')[0] === known }
  end
  unknowns.each do |unknown|
    arg = unknown.split('=')[0]
    STDERR.puts "ERROR: unknown argument [#{arg}]"
  end
  exit failed unless unknowns === []
end

# - - - - - - - - - - - - - - - - - - - - - - - - -

def exit_failure_unless_start_point_exists(type, image_name)
  unless image_exists?(image_name)
    command = "docker pull #{image_name}"
    STDOUT.puts command
    if !system(command)
      STDERR.puts "ERROR: failed to pull #{image_name}"
      exit failed
    end
  end
  unless start_point_image?(image_name)
    STDERR.puts "ERROR: #{image_name} was not created using [cyber-dojo start-point create]"
    exit failed
  end
  image_type = start_point_type(image_name)
  unless image_type == type
    STDERR.puts "ERROR: the type of #{image_name} is #{image_type} (not #{type})"
    exit failed
  end
end

# - - - - - - - - - - - - - - - - - - - - - - - - -

def pull_all_images_named_in(image_name)
  image_names = get_image_names
  get_manifests_image_names(image_name).each do |image_name|
    STDOUT.puts ">>checking #{image_name}:latest"
    if image_names.include? image_name
      STDOUT.puts ">>exists #{image_name}:latest"
    else
      STDOUT.puts ">>!exists #{image_name}:latest"
      STDOUT.puts ">>pulling #{image_name}:latest"
      system("docker pull #{image_name}:latest")
    end
  end
end

# - - - - - - - - - - - - - - - - - - - - - - - - -

def get_image_names
  `docker image ls --format {{.Repository}}`.split.sort.uniq - ['<none>']
end

# - - - - - - - - - - - - - - - - - - - - - - - - -

def get_manifests_image_names(image_name)
  stdout = cyber_dojo_start_point_inspection(image_name)
  json = JSON.parse!(stdout)
  json.values.collect { |value| value['image_name'] }.sort.uniq
end
