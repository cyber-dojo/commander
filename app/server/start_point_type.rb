
def start_point_type(image_name)
  spt('ContainerConfig', image_name) || spt('Config', image_name)
end


def spt(label_name, image_name)
  command = "docker inspect --format='{{json .#{label_name}.Labels}}' #{image_name}"
  labels = run(command)
  # returns eg {"maintainer":"jon@jaggersoft.com","org.cyber-dojo.start-points":"custom"}
  json = JSON.parse(labels)
  json.fetch('org.cyber-dojo.start-point', false)
end
