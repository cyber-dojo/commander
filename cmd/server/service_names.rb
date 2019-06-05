
def service_names
  # I'd like to get these image names directly from
  # docker-compose.yml but there does not seem to be
  # a simple way to do that :-(
  %w(
    differ
    grafana
    mapper
    nginx
    prometheus
    ragger
    runner
    saver
    web
    zipper
  )
end
