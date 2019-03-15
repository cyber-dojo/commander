
def cyber_dojo_start_points_create_dir(name, dir)
  cid = ''
  vol = ''

  # make an empty docker volume with the given name
  command = "docker volume create --name=#{name} --label=cyber-dojo-start-point=#{dir}"
  assert_run_loud(command)
  vol = name

  # mount empty volume inside docker container
  command = [
    'docker create',
      '--interactive',
      '--user=root',
      "--volume=#{name}:/data",
      "#{cyber_dojo_commander}",
      'sh'
  ].join(space)
  cid = assert_run_loud(command).strip
  assert_run_loud "docker start #{cid}"

  # fill empty volume from dir
  assert_run_loud "docker cp #{dir}/. #{cid}:/data"

  # ensure cyber-dojo user owns everything in the volume
  assert_run_loud "docker exec #{cid} sh -c 'chown -R cyber-dojo:cyber-dojo /data'"

  # is the volume a good start-point?
  assert_run_quiet "docker exec #{cid} sh -c './start_point_check.rb /data'"
  vol = '' # yes

ensure
  clean_up(cid, vol)
end
