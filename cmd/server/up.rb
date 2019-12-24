
require_relative 'start_point_type'

def cyber_dojo_server_up
  exit_success_if_up_help

          port = up_command_line['--port']      || dot_env['CYBER_DOJO_NGINX_PORT']
     custom_sp = up_command_line['--custom']    || start_point_image_name('CUSTOM')
  exercises_sp = up_command_line['--exercises'] || start_point_image_name('EXERCISES')
  languages_sp = up_command_line['--languages'] || start_point_image_name('LANGUAGES')

  exit_failure_unless_start_point_exists(   'custom', custom_sp   )
  exit_failure_unless_start_point_exists('exercises', exercises_sp)
  exit_failure_unless_start_point_exists('languages', languages_sp)

  STDOUT.puts "Using version=#{server_version} (#{server_type})"
  STDOUT.puts "Using port=#{port}"
  STDOUT.puts "Using custom-start-points=#{custom_sp}"
  STDOUT.puts "Using exercises-start-points=#{exercises_sp}"
  STDOUT.puts "Using languages-start-points=#{languages_sp}"
  service_names.each do |name|
    STDOUT.puts "Using #{name}=#{tagged_image_name(name)}"
  end

  pull_all_images_named_in(custom_sp)
  pull_all_images_named_in(languages_sp)
  STDOUT.puts

  env_vars = dot_env
  env_vars.merge!({
    'ENV_ROOT' => env_root,
    'CYBER_DOJO_NGINX_PORT' => port,
    'CYBER_DOJO_CUSTOM_START_POINTS'    => custom_sp,
    'CYBER_DOJO_EXERCISES_START_POINTS' => exercises_sp,
    'CYBER_DOJO_LANGUAGES_START_POINTS' => languages_sp,
    'CYBER_DOJO_SHA' => sha,
    'CYBER_DOJO_RELEASE' => release
  })

  apply_user_defined_env_vars(env_vars)
  create_user_defined_env_files

  if docker_swarm?
    command = "docker stack up #{docker_swarm_yml_files} cyber-dojo"
    system(env_vars, command)
  else
    command = "docker-compose #{docker_yml_files} up -d --remove-orphans"
    system(env_vars, "#{command} 2>&1")
    # A successful [docker-compose ... up] writes to stderr !?
    # See https://github.com/docker/compose/issues/3267
  end
end

# - - - - - - - - - - - - - - - - - - - - - - - - -

def start_point_image_name(name)
  image = dot_env["CYBER_DOJO_#{name}_START_POINTS_IMAGE"]
  tag = dot_env["CYBER_DOJO_#{name}_START_POINTS_TAG"]
  "#{image}:#{tag}"
end

# - - - - - - - - - - - - - - - - - - - - - - - - -

def tagged_image_name(service)
  key = "CYBER_DOJO_#{service.upcase}_IMAGE"
  image_name = ENV[key] || "cyberdojo/#{service}"
  key = "CYBER_DOJO_#{service.upcase}_TAG"
  tag = ENV[key] || dot_env[key]
  "#{image_name}:#{tag}"
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

def create_user_defined_env_files
  %w( nginx web ).each do |name|
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

def apply_user_defined_env_vars(env_vars)
  keys  = %w( CYBER_DOJO_WEB_IMAGE CYBER_DOJO_WEB_TAG )
  keys += %w( CYBER_DOJO_NGINX_IMAGE CYBER_DOJO_NGINX_TAG )
  keys.each do |key|
    if ENV[key]
      env_vars[key] = ENV[key]
    end
  end
end

# - - - - - - - - - - - - - - - - - - - - - - - - -

def exit_success_if_up_help
  minitab = ' ' * 2
  help = [
    '',
    "Use: #{me} up [OPTIONS]",
    '',
    'Creates and starts a cyber-dojo server using default/named port,',
    'and start-points unless overridden with command-line options.',
    '',
    'Command-line-arg           Default',
    '--port=NUMBER              80',
    '--custom=IMAGE_NAME        cyberdojo/custom-start-points',
    '--exercises=IMAGE_NAME     cyberdojo/exercises-start-points',
    '--languages=IMAGE_NAME     cyberdojo/languages-start-points-common',
    '',
    'The default start-point images were created using:',
    '',
    minitab + "#{me} start-point create \\",
    minitab + '  cyberdojo/custom-start-points \\',
    minitab + '    --custom \\',
    minitab + '      https://github.com/cyber-dojo/custom-start-points.git',
    '',
    minitab + "#{me} start-point create \\",
    minitab + '  cyberdojo/exercises-start-points \\',
    minitab + '    --exercises \\',
    minitab + '      https://github.com/cyber-dojo/exercises-start-points.git',
    '',
    minitab + "#{me} start-point create \\",
    minitab + '  cyberdojo/languages-start-points-common \\',
    minitab + '    --languages \\',
    minitab + '      $(curl --silent https://raw.githubusercontent.com/cyber-dojo/languages/master/url_list/common)',
    '',
    'Additionally, .env files for nginx, and web can be overriden using',
    "environment variables holding the .env file's absolute path.",
    '',
    minitab + 'CYBER_DOJO_NGINX_ENV=PATH',
    minitab + 'CYBER_DOJO_WEB_ENV=PATH',
    '',
    'Example: specify the port and custom start-point with command-line arguments',
    '',
    "  #{me} up --port=8000 --custom=acme/my-custom:latest",
    '',
    'Example: specify .env file for nginx',
    '  export CYBER_DOJO_NGINX_ENV=/Users/fred/nginx.env',
    "  #{me} up",
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
