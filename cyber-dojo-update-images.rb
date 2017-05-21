
def cyber_dojo_update_images
  # special command called directly from ./cyber-dojo
  # I'd like to get these image names directly from docker-compose.yml
  # but there does not seem to be a simple way to do that :-(
  service_images = %w(
    nginx
    web
    runner
    runner_stateless
    storer
    differ
    collector
    zipper
    prometheus
    grafana
  )
  service_images.each do |name|
    # use system() so pulls are visible in terminal
    system "docker pull cyberdojo/#{name}:latest"
  end

  cmd = "docker images --format '{{.Repository}}' | grep cyberdojofoundation"
  stdout = `#{cmd}`
  language_images = stdout.split("\n")
  language_images.each do |name|
    system "docker pull #{name}"
  end
end
