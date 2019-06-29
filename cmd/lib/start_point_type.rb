
def start_point_type(image_name)
  command = "docker inspect --format='{{json .ContainerConfig.Labels}}' #{image_name}"
  labels = run(command)
  # returns eg {"maintainer":"jon@jaggersoft.com","org.cyber-dojo.start-points":"custom"}
  json = JSON.parse(labels)
  json['org.cyber-dojo.start-point']
end
