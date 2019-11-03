
def docker_yml_files
  [
    compose_file('depends-on.yml'),
    #compose_file('swarm.yml'),
    compose_file('env-files.yml'),
    compose_file('images.yml'),
    compose_file('main.yml'),
    compose_file('ports.yml'),
    compose_file('tmp-fs.yml'),
    compose_file('volumes.yml'),
  ].join(' ')
end

def compose_file(name)
  "--file=#{__dir__}/../docker-compose/#{name}"
end
