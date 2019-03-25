
def cyber_dojo_start_point_rm
  help = [
    '',
    "Use: #{me} start-point rm IMAGE_NAME",
    '',
    "Removes a start-point image created with the [#{me} start-point create] command"
  ]

  image_name = ARGV[2]
  if [nil,'-h','--help'].include?(image_name)
    show help
    exit succeeded
  end

  exit_unless_start_point_image(image_name)

  unless ARGV[3].nil?
    puts "FAILED: unknown argument [#{ARGV[3]}]"
    exit failed
  end

  run("docker image rm #{image_name} &> /dev/null")
  if $exit_status != 0
    puts "FAILED cannot remove start-point #{image_name}"
    exit failed
  end

end
