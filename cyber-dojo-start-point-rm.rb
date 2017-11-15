
def cyber_dojo_start_point_rm
  # Allow deletion of a default volume.
  # This allows you to create custom default volumes.
  help = [
    '',
    "Use: #{me} start-point rm NAME",
    '',
    "Removes a start-point created with the [#{me} start-point create] command"
  ]

  vol = ARGV[2]
  if [nil,'--help'].include? vol
    show help
    exit succeeded
  end

  exit_unless_is_cyber_dojo_volume(vol, 'rm')

  unless ARGV[3].nil?
    puts "FAILED: unknown argument [#{ARGV[3]}]"
    exit failed
  end

  run "docker volume rm #{vol} &> /dev/null"
  if $exit_status != 0
    puts "FAILED cannot remove start-point #{vol}. Is it in use?"
    exit failed
  end

end

