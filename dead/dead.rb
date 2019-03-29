
def XXX_exit_unless_is_cyber_dojo_volume(vol, command)
  unless volume_exists? vol
    STDERR.puts "FAILED: #{vol} does not exist."
    exit failed
  end
  unless cyber_dojo_volume? vol
    STDERR.puts "FAILED: #{vol} is not a cyber-dojo start-point."
    exit failed
  end
end

def XXX_volume_exists?(name)
  # careful to match whole string
  start_of_line = '^'
  end_of_line = '$'
  pattern = "#{start_of_line}#{name}#{end_of_line}"
  run("docker volume ls --quiet | grep '#{pattern}'").include? name
end

def XXX_cyber_dojo_volume?(vol)
  labels = cyber_dojo_inspect(vol)['Labels'] || []
  labels.include? 'cyber-dojo-start-point'
end

def XXX_cyber_dojo_label(vol)
  cyber_dojo_inspect(vol)['Labels']['cyber-dojo-start-point']
end

def XXX_cyber_dojo_type(vol)
  cyber_dojo_data_manifest(vol)['type']
end

def XXX_cyber_dojo_data_manifest(vol)
  command = quoted "cat /data/start_point_type.json"
  JSON.parse(run "docker run --rm -v #{vol}:/data #{cyber_dojo_commander} sh -c #{command}")
end

def XXX_cyber_dojo_inspect(vol)
  info = run("docker volume inspect #{vol}")
  JSON.parse(info)[0]
end
