
def cyber_dojo_update
  help = [
    '',
    "Use: #{me} update [OPTIONS]",
    '',
    'Updates all cyber-dojo server and language images and the cyber-dojo script file',
    '',
    minitab + 'server      update the server images and the cyber-dojo script file',
    minitab + '            but not the current languages',
    '',
    minitab + 'languages   update the current languages but not the',
    minitab + '            server images or the cyber-dojo script file'
  ]

  if ARGV[1] == '--help'
    show help
    exit succeeded
  end

  # unknown arguments?
  args = ARGV[1..-1]
  knowns = ['server','languages']
  unknowns = args.select do |arg|
    knowns.none? { |known| arg == known }
  end
  unknowns.each do |arg|
    STDERR.puts "FAILED: unknown argument [#{arg}]"
  end
  exit failed unless unknowns == []

  if ARGV[1].nil? || ARGV[1] == 'server'
    cyber_dojo_update_server
  end
  if ARGV[1].nil? || ARGV[1] == 'languages'
    cyber_dojo_update_languages
  end
  # cyber-dojo script updates itself
end

# - - - - - - - - - - - - - - - - - - - - - - - - - - -

def cyber_dojo_update_server
  # I'd like to get these image names directly from docker-compose.yml
  # but there does not seem to be a simple way to do that :-(
  service_images = %w(
    nginx
    web
    runner_stateless
    runner_stateful
    runner_processful
    starter
    storer
    differ
    collector
    zipper
    prometheus
    grafana
  )
  service_images.each do |name|
    # use system() so pulls are visible in terminal
    system "docker pull cyberdojo/#{name}:latest"
  end
end

# - - - - - - - - - - - - - - - - - - - - - - - - - - -

def cyber_dojo_update_languages
  cmd = "docker images --format '{{.Repository}}' | grep cyberdojofoundation"
  stdout = `#{cmd}`
  language_images = stdout.split("\n")
  language_images.each do |name|
    system "docker pull #{name}"
  end
end
