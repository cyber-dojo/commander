require 'date'

def versioner
  'cyberdojo/versioner:latest'
end

def versioner_env_vars
  $versioner_env_vars ||= read_versioner_env_vars
end

def read_versioner_env_vars
  src = `docker run --rm #{versioner} sh -c 'env'`
  env_file_to_h(src)
end

def sha
  versioner_env_vars['SHA']
end

def sha7
  sha[0...7]
end

def release
  versioner_env_vars['RELEASE']
end

def release?
  !release.empty?
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
  DateTime.iso8601(dt).strftime('%Y-%m-%d %H:%M:%S')
end

def cyber_dojo_server_version
  puts "Version: #{server_version}"
  puts "   Type: #{server_type}"
  puts "Created: #{ymd_hms(server_date)}"
end
