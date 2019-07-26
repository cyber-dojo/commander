
def dot_env
  $dot_env ||= begin
    #src = `docker run --rm cyberdojo/versioner:latest ruby /app/src/echo_env_vars.rb`
    src = `docker run --rm cyberdojo/versioner:latest sh -c 'cat /app/.env'`
    env_file_to_h(src)
  end
end
