
def cyber_dojo_clean
  help = [
    '',
    "Use: #{me} clean",
    '',
    'Removes dangling docker images/volumes and exited containers',
  ]

  if ARGV[1] == '--help'
    show help
    exit succeeded
  end

  ARGV[1..-1].each do |arg|
    STDERR.puts "FAILED: unknown argument [#{arg}]"
  end
  unless ARGV[1].nil?
    exit failed
  end

  command = "docker images --quiet --filter='dangling=true' | xargs --no-run-if-empty docker rmi --force"
  run command
  command = "docker ps --all --quiet --filter='status=exited' | xargs --no-run-if-empty docker rm --force"
  run command

  # TODO: Bug - this removes start-point volumes
  #       if the cyber-dojo server is down
  #
  #command = "docker volume ls --quiet --filter='dangling=true' | xargs --no-run-if-empty docker volume rm"
  #run command
end
