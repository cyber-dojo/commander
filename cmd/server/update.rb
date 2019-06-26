
def cyber_dojo_server_update
  exit_success_if_update_help
  exit_failure_if_too_many_arguments

  # set tag for outgoing :latest
  versioner = 'cyberdojo/versioner:latest'
  was = `docker run --rm #{versioner} sh -c 'echo -n ${RELEASE}'`
  if !was.empty?
    `docker tag #{versioner} cyberdojo/versioner:#{was}`
  else
    was_sha = `docker run #{versioner} sh -c 'echo -n ${SHA}'`
    was_tag = was_sha[0...7]
    `docker tag #{versioner} cyberdojo/versioner:#{was_tag}`
  end

  tag = ARGV[1] || 'latest'
  run "docker pull cyberdojo/versioner:#{tag}"
  exit(5) if $exit_status != 0
  run "docker tag cyberdojo/versioner:#{tag} cyberdojo/versioner:latest"
  exit(5) if $exit_status != 0
end

# - - - - - - - - - - - - - - - - - - - - - - - - - -

def exit_success_if_update_help
  help = [
    '',
    'Use: cyber-dojo update [latest|RELEASE|TAG]',
    '',
    'Updates image tags ready for the next [cyber-dojo up] command.',
    '',
    'Example 1: update to latest',
    '',
    'cyber-dojo update',
    'cyber-dojo version',
    '...',
    'Version: 1.0.34',
    '   Type: public',
    '...',
    '',
    'Example 2: update to a given public release',
    '',
    'cyber-dojo update 1.0.23', 
    'cyber-dojo version',
    'Version: 1.0.23',
    '   Type: public',
    '',
    'Example 3: update to a given development tag',
    '',
    'cyber-dojo update 677df27',
    'cyber-dojo version',
    'Version: 677df27',
    '   Type: development',
    ''
  ]
  if ['-h','--help'].include?(ARGV[1])
    show help
    exit succeeded
  end
end

# - - - - - - - - - - - - - - - - - - - - - - - - - -

def exit_failure_if_too_many_arguments
  unless ARGV[2].nil?
    args = ARGV[1..-1]
    STDERR.puts "ERROR: too many arguments [#{args.join(' ')}]"
  end
end
