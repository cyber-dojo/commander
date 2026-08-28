require 'date'

def cyber_dojo_server_update
  exit_success_if_update_help
  exit_failure_if_too_many_arguments

  # set tag for outgoing :latest
  versioner = 'cyberdojo/versioner:latest'
  was = `docker run --entrypoint "" --rm #{versioner} sh -c 'echo -n ${RELEASE}'`
  if !was.empty?
    `docker tag #{versioner} cyberdojo/versioner:#{was}`
  else
    was_sha = `docker run --entrypoint "" --rm #{versioner} sh -c 'echo -n ${SHA}'`
    was_tag = was_sha[0...7]
    `docker tag #{versioner} cyberdojo/versioner:#{was_tag}`
  end

  tag = ARGV[1]
  run "docker pull cyberdojo/versioner:#{tag}"
  exit(5) if $exit_status != 0
  exit_failure_if_too_old_to_run(tag)
  run "docker tag cyberdojo/versioner:#{tag} cyberdojo/versioner:latest"
  exit(5) if $exit_status != 0
end

# - - - - - - - - - - - - - - - - - - - - - - - - - -

# 0.1.329 is the oldest release whose commander reads .Config.Labels. Older
# ones read only .ContainerConfig.Labels, which docker no longer returns from
# [docker inspect], so their [cyber-dojo up] cannot work.
OLDEST_RUNNABLE_RELEASE = '0.1.329'
OLDEST_RUNNABLE_DATE = '2023-03-25'

def exit_failure_if_too_old_to_run(tag)
  # Ranking by the versioner image's creation date orders public releases and
  # development tags alike, and reads the image the pull above just fetched, so
  # it costs no extra download. An unreadable date lets the update proceed,
  # keeping a docker hiccup from blocking an otherwise fine upgrade.
  created = run("docker inspect --format='{{ .Created }}' cyberdojo/versioner:#{tag}").strip
  return if created.empty?
  return if Date.iso8601(created) >= Date.iso8601(OLDEST_RUNNABLE_DATE)
  STDERR.puts "ERROR: #{tag} predates #{OLDEST_RUNNABLE_RELEASE} and cannot run on this docker."
  STDERR.puts 'Its images read .ContainerConfig.Labels, which docker no longer provides.'
  STDERR.puts "No update was made. Use [#{me} update #{OLDEST_RUNNABLE_RELEASE}] or later."
  exit(failed)
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
    'cyber-dojo update latest',
    'cyber-dojo version',
    '...',
    'Version: 0.1.155',
    '   Type: public',
    '...',
    '',
    'Example 2: update to a given public release',
    '',
    'cyber-dojo update 0.1.123',
    'cyber-dojo version',
    'Version: 0.1.123',
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
  if ['-h','--help',nil].include?(ARGV[1])
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
