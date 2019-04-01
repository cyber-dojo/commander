
def cyber_dojo_clean
  help = [
    '',
    "Use: #{me} clean",
    '',
    'Removes dangling docker images/volumes and exited containers',
  ]

  if ['-h','--help'].include?(ARGV[1])
    show help
    exit succeeded
  end

  ARGV[1..-1].each do |arg|
    STDERR.puts "FAILED: unknown argument [#{arg}]"
  end
  unless ARGV[1].nil?
    exit failed
  end

  run('docker system prune --force')
end
