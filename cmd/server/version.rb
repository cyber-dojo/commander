require 'date'

def versioner
  'cyberdojo/versioner:latest'
end

def release
  $release ||= `docker run --rm #{versioner} sh -c 'echo -n ${RELEASE}'`
end

def release?
  !release.empty?
end

def sha7
  $sha7 ||= `docker run --rm #{versioner} sh -c 'echo -n ${SHA:0:7}'`
end

def server_version
  release? ? release : sha7
end

def server_type
  release? ? 'public' : 'development'
end

def server_date
  $when ||= `docker inspect -f '{{ .Created }}' #{versioner}`
end

def ymd_hms(dt)
  DateTime.iso8601(dt).strftime('%Y-%M-%d %H:%M:%S')
end

def cyber_dojo_server_version
  puts "Version: #{server_version}"
  puts "Type: #{server_type}"
  puts "Created: #{ymd_hms(server_date)}"
end
