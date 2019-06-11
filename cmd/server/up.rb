
def cyber_dojo_server_up
  exit_success_if_up_help

       port = up_argument('port')
     custom = up_argument('custom')
  exercises = up_argument('exercises')
  languages = up_argument('languages')

  exit_failure_unless_start_point_exists(   'custom', custom   )
  exit_failure_unless_start_point_exists('exercises', exercises)
  exit_failure_unless_start_point_exists('languages', languages)

  STDOUT.puts "Using version=#{server_version} (#{server_type})"
  STDOUT.puts "Using port=#{port}"
  STDOUT.puts "Using custom=#{custom}"
  STDOUT.puts "Using exercises=#{exercises}"
  STDOUT.puts "Using languages=#{languages}"
  service_names.each do |name|
    STDOUT.puts "Using #{name}=#{tagged_image_name(name)}"
  end

  pull_all_images_named_in(custom)
  pull_all_images_named_in(languages)
  STDOUT.puts

  env_vars = {
    'ENV_ROOT' => env_root,
    'CYBER_DOJO_PORT' => port,
    'CYBER_DOJO_CUSTOM'    => custom,
    'CYBER_DOJO_EXERCISES' => exercises,
    'CYBER_DOJO_LANGUAGES' => languages,
  }
  add_services_image_tags(env_vars)

  use_any_custom_env_files

  system(env_vars, "#{docker_compose_cmd} up -d 2>&1")
  # A successful [docker-compose ... up] writes to stderr !?
  # See https://github.com/docker/compose/issues/3267
end

# - - - - - - - - - - - - - - - - - - - - - - - - -

def up_argument(name)
  key = "CYBER_DOJO_#{name.upcase}"
  option = "--#{name}"
  ENV[key] || up_command_line[option] || dot_env[key]
end

# - - - - - - - - - - - - - - - - - - - - - - - - -

def tagged_image_name(service)
  key = "CYBER_DOJO_#{service.upcase}_SHA"
  sha = dot_env[key]
  tag = sha[0...7]
  "cyberdojo/#{service}:#{tag}"
end

# - - - - - - - - - - - - - - - - - - - - - - - - -

def up_command_line
  args = {}
  bad = []
  knowns = %w( --port --custom --exercises --languages )
  ARGV[1..-1].each do |arg|
    name,value = arg.split('=',2)
    if knowns.none?{ |known| name === known }
      bad << "ERROR: unknown argument [#{name}]"
    elsif value.nil? || value.empty?
      bad << "ERROR: missing argument value #{name}=[???]"
    else
      args[name.strip] = value.rstrip
    end
  end
  unless bad === []
    bad.each { |msg| STDERR.puts msg }
    exit failed
  end
  args
end

# - - - - - - - - - - - - - - - - - - - - - - - - -

def use_any_custom_env_files
  unless File.exist?("#{env_root}/custom.grafana.env")
    puts 'WARNING: Using default grafana admin password.'
    puts 'To set your own password and remove this warning:'
    puts '   1. Create a file with contents'
    puts '      GF_SECURITY_ADMIN_PASSWORD=mypassword'
    puts '   2. export CYBER_DOJO_GRAFANA_ENV=<its-fully-pathed-filename>'
    puts '   3. Re-issue the command [cyber-dojo up ...]'
    puts '   4. Verify you do not get this warning'
  end
  %w( grafana nginx web ).each do |name|
    path = ENV["CYBER_DOJO_#{name.upcase}_ENV"]
    from = "#{env_root}/custom.#{name}.env"
      to = "#{env_root}/#{name}.env"
    if File.exist?(from)
      puts "Using #{name}.env=#{path} (custom)"
      content = IO.read(from)
      File.open(to, 'w') { |file| file.write(content) }
    else
      puts "Using #{name}.env=default"
    end
  end
end

# - - - - - - - - - - - - - - - - - - - - - - - - -

def add_services_image_tags(env_vars)
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
    'Settings can be specified with environment variables, and command line',
    'arguments, with the former taking precedence.',
    '',
    'Environment variables:',
    minitab + 'CYBER_DOJO_CUSTOM=NAME      Specify the custom start-point name.',
    minitab + 'CYBER_DOJO_EXERCISES=NAME   Specify the exercises start-point name.',
    minitab + 'CYBER_DOJO_LANGUAGES=NAME   Specify the languages start-point name.',
    minitab + 'CYBER_DOJO_PORT=NUMBER      Specify the port number.',
    '',
    'Command line arguments:',
    minitab + '--custom=NAME               Specify the custom start-point name.',
    minitab + '--exercises=NAME            Specify the exercises start-point name.',
    minitab + '--languages=NAME            Specify the languages start-point name.',
    minitab + '--port=NUMBER               Specify the port number.',
    '',
    'Defaults:',
    minitab + '--custom=cyberdojo/custom',
    minitab + '--exercises=cyberdojo/exercises',
    minitab + '--languages=cyberdojo/languages-common',
    minitab + '--port=80',
    '',
    'Default start-points were created using:',
    minitab + 'cyber-dojo start-point create \\',
    minitab + '  cyberdojo/custom \\',
    minitab + '    --custom \\',
    minitab + '      https://github.com/cyber-dojo/custom.git',
    '',
    minitab + 'cyber-dojo start-point create \\',
    minitab + '  cyberdojo/exercises \\',
    minitab + '    --exercises \\',
    minitab + '      https://github.com/cyber-dojo/exercises.git',
    '',
    minitab + 'cyber-dojo start-point create \\',
    minitab + '  cyberdojo/languages-common \\',
    minitab + '    --languages \\',
    minitab + '      $(curl --silent https://raw.githubusercontent.com/cyber-dojo/languages/master/url_list/common)',
  ]
  if ['-h','--help'].include?(ARGV[1])
    show help
    exit succeeded
  end
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

def pull_all_images_named_in(start_point_image_name)
  image_names = get_image_names
  get_manifests_image_names(start_point_image_name).each do |ltf|
    STDOUT.print('.')
    unless image_names.include?(ltf)
      system("docker pull #{ltf}")
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
