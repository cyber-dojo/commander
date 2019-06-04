
def cyber_dojo_server_update
  if ['-h','--help'].include?(ARGV[1])
    exit succeeded
  end

  if ARGV[1..-1] === []
    cyber_dojo_update_server
  end
  # cyber-dojo script updates itself
end

# - - - - - - - - - - - - - - - - - - - - - - - - - - -

def cyber_dojo_update_server
  service_names.each do |name|
    # use system() so pulls are visible in terminal
    system "docker pull cyberdojo/#{name}:latest"
  end
end
