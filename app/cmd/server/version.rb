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
  exit_success_if_version_help
  if ARGV[1] === 'ls'
    stdout = `docker images --format "table {{.Tag}}\t{{.CreatedAt}}" cyberdojo/versioner`
    puts stdout.lines.select{ |line| line.include?('.') }.sort.reverse
  elsif ARGV[1].nil?
    puts "Version: #{server_version}"
    puts "   Type: #{server_type}"
    puts "Created: #{ymd_hms(server_date)}"
  end
end

def exit_success_if_version_help
  minitab = ' ' * 2
  help = [
    '',
    "Use: #{me} version [ls]",
    '',
    'To print the current version:',
    "$ #{me} version",
    'Version: 0.1.49',
    'Type: public',
    'Created: 2019-11-21 21:31:09',
    '',
    'To print all installed versions:',
    "$ #{me} version ls",
    '0.1.49              2019-11-21 21:31:09 +0000 UTC',
    '0.1.48              2019-11-20 12:52:04 +0000 UTC',
    '0.1.40              2019-11-06 10:48:58 +0000 UTC',
    '0.1.35              2019-09-27 07:14:23 +0000 UTC'
  ]
  if ['-h','--help'].include?(ARGV[1])
    show help
    exit succeeded
  end
end
