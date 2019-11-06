
def docker_swarm?
  ENV['CYBER_DOJO_SWARM']
end

def docker_swarm_yml_files
  docker_common_yml_files +
    ' ' + compose_file('swarm.yml')
end

def docker_yml_files
  docker_common_yml_files +
    ' ' + compose_file('restart.yml')
    ' ' + compose_file('container-name.yml') 
end

def docker_common_yml_files
  [
    compose_file('depends-on.yml'),
    compose_file('env-files.yml'),
    compose_file('images.yml'),
    compose_file('main.yml'),
    compose_file('ports.yml'),
    compose_file('tmp-fs.yml'),
    compose_file('volumes.yml'),
  ].join(' ')
end

def compose_file(name)
  location = "#{__dir__}/../docker-compose/#{name}"
  if docker_swarm?
    "--compose-file #{location}"
  else
    "--file=#{location}"
  end
end
