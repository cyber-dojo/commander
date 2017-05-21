
def cyber_dojo_update
  help = [
    '',
    "Use: #{me} update",
    '',
    'Updates all cyber-dojo docker images and the cyber-dojo script file'
  ]

  if ARGV[1] == '--help'
    show help
    exit succeeded
  end

  unless ARGV[1].nil?
    STDERR.puts "FAILED: unknown argument [#{ARGV[1]}]"
    exit failed
  end
  # cyber-dojo script does actual [update]
end
