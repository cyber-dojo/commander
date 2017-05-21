
def cyber_dojo_logs
  help = [
    '',
    "Use: #{me} logs",
    '',
    "Fetches and prints the logs of the web server (if running)",
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
    puts "FAILED: cannot show logs - the web server is not running"
    exit failed
  else
    puts `docker logs #{web_container_name}`
  end
end
