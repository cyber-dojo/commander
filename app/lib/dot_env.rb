
def dot_env
  $dot_env ||= begin
    src = `docker run --rm cyberdojo/versioner:latest`
    # versioner does not yet emit spooler env-vars, so append them here until it
    # does, then delete this line and spooler_env_vars (a matching TODO lives in
    # the spooler repo's bin/echo_env_vars.sh).
    src += spooler_env_vars
    env_file_to_h(src)
  end
end

# The spooler env-vars versioner does not emit yet, as appendable KEY=value
# lines. TODO: delete once cyberdojo/versioner emits them. The sha must match a
# published cyberdojo/spooler image.
def spooler_env_vars
  sha = '76b46ec320e531f9dfbc88c8b613e49a741c9d21'
  [
    '',
    'CYBER_DOJO_SPOOLER_IMAGE=cyberdojo/spooler',
    "CYBER_DOJO_SPOOLER_SHA=#{sha}",
    "CYBER_DOJO_SPOOLER_TAG=#{sha[0, 7]}",
    'CYBER_DOJO_SPOOLER_PORT=4539'
  ].join("\n")
end
