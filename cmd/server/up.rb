
require_relative 'start_point_type'

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

  env_vars = dot_env
  env_vars.merge!({
    'ENV_ROOT' => env_root,
    'CYBER_DOJO_PORT' => port,
    'CYBER_DOJO_CUSTOM'    => custom,
    'CYBER_DOJO_EXERCISES' => exercises,
    'CYBER_DOJO_LANGUAGES' => languages,
    'CYBER_DOJO_SHA' => sha,
    'CYBER_DOJO_RELEASE' => release
  })

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

def exit_success_if_up_help
  minitab = ' ' * 2
  help = [
    '',
    "Use: #{me} up [OPTIONS]",
    '',
    'Creates and starts a cyber-dojo server using default/named port,',
    'and start-points. Settings can be specified with environment variables',
    'and command-line arguments, with the former taking precedence.',
    '',
    'Environment-variable        Command-line-arg     Default',
    'CYBER_DOJO_PORT=NUMBER      --port=NUMBER        NUMBER=80',
    'CYBER_DOJO_CUSTOM=NAME      --custom=NAME        NAME=cyberdojo/custom',
    'CYBER_DOJO_EXERCISES=NAME   --exercises=NAME     NAME=cyberdojo/exercises',
    'CYBER_DOJO_LANGUAGES=NAME   --languages=NAME     NAME=cyberdojo/languages-common',
    '',
    'Example 1: specify port with environment variable:',
    '',
    '  export CYBER_DOJO_PORT=81',
    "  #{me} up",
    '',
    'Example 2: specify port and languages start-point with command-line arguments',
    '',
    "  #{me} up --port=81 --languages=cyberdojo/languages-all",
    '',
    'The default start-points were created using:',
    minitab + "#{me} start-point create \\",
    minitab + '  cyberdojo/custom \\',
    minitab + '    --custom \\',
    minitab + '      https://github.com/cyber-dojo/custom.git',
    '',
    minitab + "#{me} start-point create \\",
    minitab + '  cyberdojo/exercises \\',
    minitab + '    --exercises \\',
    minitab + '      https://github.com/cyber-dojo/exercises.git',
    '',
    minitab + "#{me} start-point create \\",
    minitab + '  cyberdojo/languages-common \\',
    minitab + '    --languages \\',
    minitab + '      $(curl --silent https://raw.githubusercontent.com/cyber-dojo/languages/master/url_list/common)',
    '',
    'Additionally, .env files for nginx, and web can be overriden using',
    "environment variables holding the .env file's absolute path.",
    '',
    minitab + 'CYBER_DOJO_NGINX_ENV=PATH',
    minitab + 'CYBER_DOJO_WEB_ENV=PATH',
    '',
    'Example 3: specify .env file for nginx',
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
