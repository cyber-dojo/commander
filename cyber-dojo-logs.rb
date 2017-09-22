
def cyber_dojo_logs
  help = [
    '',
    "Use: #{me} logs SERVICE",
    '',
    'Prints the logs from a service container',
    "Example: #{me} logs web",
    "Example: #{me} logs storer",
    "Example: #{me} logs runner"
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

  name = 'cyber-dojo-' + service
  unless service_running(name)
    STDERR.puts "FAILED: #{name} is not a running container"
    exit failed
  else
    puts `docker logs #{name}`
  end
end
