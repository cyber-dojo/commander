
def start_point_image?(image_name)
  # [docker image ls] lists image names with their tag (eg :latest)
  # but image_name may be tagless and defaulting to :latest
  cmd  = 'docker image ls'
  cmd += " --filter 'label=org.cyber-dojo.start-point'"
  cmd += " --format '{{.Repository}}:{{.Tag}}'"
  names = run(cmd).split
  names.include?(image_name) || names.include?(image_name + ':latest')
end
