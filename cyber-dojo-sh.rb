
def cyber_dojo_sh
  help = [
    '',
    "Use: #{me} sh",
    '',
    "Shells into the cyber-dojo web server docker container",
  ]

  if ARGV[1] == '--help'
    show help
    exit succeeded
  end

  unless ARGV[1].nil?
    STDERR.puts "FAILED: unknown argument [#{ARGV[1]}]"
    exit failed
  end

  unless web_server_running
    puts "FAILED: cannot shell in - the web server is not running"
    exit failed
  end
  # cyber-dojo.sh does actual [sh]
end
