
def image_exists?(image_name)
  cmd  = 'docker image ls'
  cmd += " --filter=reference=#{image_name}"
  cmd += " --format '{{.Repository}}:{{.Tag}}'"
  run(cmd).split != []
end
