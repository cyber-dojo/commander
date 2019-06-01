
def docker_compose_cmd
  my_dir = File.dirname(__FILE__)
  [
    'docker-compose',
    "--file=#{my_dir}/../../docker-compose.yml",
    "--file=#{my_dir}/../../docker-compose.cpu-shares.yml",
    "--file=#{my_dir}/../../docker-compose.depends-on.yml",
    "--file=#{my_dir}/../../docker-compose.env-files.yml",
    "--file=#{my_dir}/../../docker-compose.images.yml"
  ].join(' ')
end
