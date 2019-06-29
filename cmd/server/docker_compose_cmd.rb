
def docker_compose_cmd
  [
    'docker-compose',
      compose_file('cpu-shares.yml'),
      compose_file('depends-on.yml'),
      compose_file('env-files.yml'),
      compose_file('images.yml'),
      compose_file('main.yml'),
      compose_file('mem-limits.yml'),
      compose_file('ports.yml'),
      compose_file('volumes.yml'),
  ].join(' ')
end

def compose_file(name)
  "--file=#{__dir__}/../docker-compose/#{name}"
end
