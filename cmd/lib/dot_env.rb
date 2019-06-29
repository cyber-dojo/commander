
def dot_env
  $dot_env ||= begin
    src = `docker run --rm cyberdojo/versioner:latest ruby /app/src/echo_env_vars.rb`
    env_file_to_h(src)
  end
end
