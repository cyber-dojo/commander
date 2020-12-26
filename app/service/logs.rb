
def cyber_dojo_service_logs
  help = [
    '',
    "Use: #{me} logs SERVICE",
    '',
    'Prints the logs from a service container',
    "Example: #{me} logs web",
    "Example: #{me} logs saver"
  ]

  service = ARGV[1]
  if [nil,'-h','--help'].include?(service)
    show help
    exit succeeded
  end

  if ARGV.size > 2
    show help
    exit failed
  end

  name = "cyber_dojo_#{service}"
  unless service_running(name)
    STDERR.puts "ERROR: #{name} is not a running container"
    exit failed
  end

  `docker logs #{name}`
end

# - - - - - - - - - - - - - - - - - - - - -

def service_running(name)
  service = `docker ps --format '{{.Names}}' --filter "name=#{name}"`
  service != ''
end
