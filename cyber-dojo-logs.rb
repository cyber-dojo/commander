
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

  ARGV[1..-1].each do |arg|
    STDERR.puts "FAILED: unknown argument [#{arg}]"
  end
  unless ARGV[1].nil?
    exit failed
  end

  unless web_server_running
    puts "FAILED: cannot show logs - the web server is not running"
    exit failed
  else
    puts `docker logs #{web_container_name}`
  end
end
