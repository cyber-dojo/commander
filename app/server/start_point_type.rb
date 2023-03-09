
def start_point_type(image_name)
  # The format for new images is .Config.Labels
  # However, in the past this was .ContainerConfig.Labels
  begin
    spt('Config', image_name)
  rescue
    spt('ContainerConfig', image_name)
  end
end


def spt(label_name, image_name)
  command = "docker inspect --format='{{json .#{label_name}.Labels}}' #{image_name}"
  labels = run(command)
  # returns eg { "maintainer": "jon@jaggersoft.com", "org.cyber-dojo.start-points": "custom" }
  json = JSON.parse(labels)
  json['org.cyber-dojo.start-point']
end
