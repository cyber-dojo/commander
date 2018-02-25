#!/usr/bin/env ruby

# Pulls docker images named in manifest.json files below path
# that have not already been pulled.

require 'json'

def failed; 1; end

def path; ARGV[0]; end

def show_use(message = '')
  STDERR.puts
  STDERR.puts 'USE: start_point_exist.rb PATH'
  STDERR.puts
  STDERR.puts "   ERROR: #{message}" if message != ''
  STDERR.puts
end

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

def manifests_image_names
  image_names = []
  Dir.glob("#{path}/**/manifest.json").each do |filename|
    content = IO.read(filename)
    manifest = JSON.parse(content)
    image_names << manifest['image_name']
  end
  image_names
end

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

if path.nil?
  show_use
  exit failed
end

if !File.directory?(path)
  show_use "#{path} not found"
  exit failed
end

image_names = `docker images --format {{.Repository}}`.split - ['<none>']
manifests_image_names.sort.uniq.each do |image_name|
  STDOUT.puts ">>checking #{image_name}:latest"
  if image_names.include? image_name
    STDOUT.puts ">>exists #{image_name}:latest"
  else
    STDOUT.puts ">>!exists #{image_name}:latest"
    STDOUT.puts ">>pulling #{image_name}:latest"
    system("docker pull #{image_name}:latest")
  end
end
