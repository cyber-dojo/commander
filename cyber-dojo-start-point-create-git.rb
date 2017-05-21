
def cyber_dojo_start_point_create_git(name, git)

  if volume_exists? name
    STDERR.puts "A start-point called #{name} already exists"
    exit failed
  end

  # 1. make an empty docker volume
  assert_run "docker volume create --name=#{name} --label=cyber-dojo-start-point"
  $g_vol = name

  # 2. mount empty docker volume inside docker container
  command = [
    'docker create',
      '--interactive',
      '--user=root',
      "--volume=#{name}:/data",
      "#{cyber_dojo_commander}",
      'sh'
  ].join(space)
  $g_cid = assert_run(command).strip
  assert_run "docker start #{$g_cid}"

  # 3. pull git repo into docker volume
  start_point_git_sparse_pull git, git.split('/')[-1]

  # 4. ensure cyber-dojo user owns everything in the volume
  assert_run "docker exec #{$g_cid} sh -c 'chown -R cyber-dojo:cyber-dojo /data'"

  # 5. check the volume is a good start-point
  run "docker exec #{$g_cid} sh -c './start_point_check.rb /data'"
  if $exit_status != 0
    clean_up
    exit failed
  end

  # TODO: put in rescue statement
  # 6. clean up everything used to create the volume, but not the volume itself
  $g_vol = ''
  clean_up
end
