
def cyber_dojo_server_update
  help = [
    '',
    "Use: #{me} update",
    '',
    'Updates all cyber-dojo server images and the cyber-dojo script file',
  ]

  if ['-h','--help'].include?(ARGV[1])
    show help
    exit succeeded
  end

  # unknown arguments?
  args = ARGV[1..-1]
  args.each do |arg|
    STDERR.puts "ERROR: unknown argument [#{arg}]"
  end
  exit failed unless args == []

  cyber_dojo_update_server
  # cyber-dojo script updates itself
end

# - - - - - - - - - - - - - - - - - - - - - - - - - - -

def cyber_dojo_update_server
  # I'd like to get these image names directly from docker-compose.yml
  # but there does not seem to be a simple way to do that :-(
  service_images = %w(
    differ
    grafana
    mapper
    nginx
    prometheus
    runner
    saver
    web
    zipper
    ragger
  )
  service_images.each do |name|
    # use system() so pulls are visible in terminal
    system "docker pull cyberdojo/#{name}:latest"
  end
end
