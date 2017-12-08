
def cyber_dojo_sh
  help = [
    '',
    "Use: #{me} sh SERVICE",
    '',
    'Shells into a service container',
    "Example: #{me} sh web",
    "Example: #{me} sh storer"
  ]

  service = ARGV[1]
  if [nil,'--help'].include? service
    show help
    exit succeeded
  end

  if ARGV.size > 2
    show help
    exit failed
  end

  name = "cyber-dojo-#{service}"
  unless service_running(name)
    STDERR.puts "FAILED: #{name} is not a running container"
    exit failed
  end

  puts "shelling into #{name}"
  cmd = "export PS1='[cyber-dojo sh #{service}] \\w $ ';sh"
  docker_cmd = "docker exec --interactive --tty #{name} sh -c \"#{cmd}\""
  system(docker_cmd)

end
