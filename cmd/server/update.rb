
def cyber_dojo_server_update
  exit_success_if_update_help

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
  system("docker pull cyberdojo/versioner:#{tag}")
  system("docker tag cyberdojo/versioner:#{tag} cyberdojo/versioner:latest")

end

def exit_success_if_update_help
  help = [
    '',
    'Use: cyber-dojo update [latest|TAG]',
    '',
    'Updates all cyber-dojo server images and the cyber-dojo script file'
  ]
  if ['-h','--help'].include?(ARGV[1])
    show help
    exit succeeded
  end
end
