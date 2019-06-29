
def exit_unless_start_point_image(image_name)
  unless image_exists?(image_name)
    STDERR.puts "ERROR: #{image_name} does not exist."
    exit failed
  end
  unless start_point_image?(image_name)
    STDERR.puts "ERROR: #{image_name} is not a cyber-dojo start-point image."
    exit failed
  end
end
