#!/usr/bin/env ruby

# Shows details of the start-point volume that has been mounted to path.
# Not (necessarily) related to the details of what start-point volumes are
# inside the running web container.

require 'json'

display_name_title = 'DISPLAY_NAME'
image_name_title   = 'IMAGE_NAME'

$longest_display_name = display_name_title
$longest_image_name = image_name_title

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

def failed; 1; end

def path; ARGV[0]; end

def show_use(message = '')
  STDERR.puts
  STDERR.puts 'USE: start_point_inspect.rb PATH'
  STDERR.puts
  STDERR.puts "   ERROR: #{message}" if message != ''
  STDERR.puts
end

def spacer(longest, name)
  ' ' * (longest.size - name.size)
end

def inspect_line(display_name, image_name, pulled)
  display_name_spacer = spacer($longest_display_name, display_name)
  image_name_spacer = spacer($longest_image_name, image_name)
  gap = ' ' * 3
  line = ''
  line += display_name + display_name_spacer + gap
  line += image_name + image_name_spacer + gap
  line += pulled
end

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

def docker_images_pulled
  `docker images`.split("\n").drop(1).map{ |line| line.split[0] }.sort - ['<none>']
  # eg
  # REPOSITORY                               TAG     IMAGE ID     CREATED      SIZE
  # cyberdojofoundation/visual-basic_nunit   latest  eb5f54114fe6 4 months ago 497.4 MB
  # cyberdojofoundation/ruby_mini_test       latest  c7d7733d5f54 4 months ago 793.4 MB
  # cyberdojofoundation/ruby_rspec           latest  ce9425d1690d 4 months ago 411.2 MB
  # -->
  # cyberdojofoundation/visual-basic_nunit
  # cyberdojofoundation/ruby_mini_test
  # cyberdojofoundation/ruby_rspec
end

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

def max_size(lhs, rhs)
  lhs.size > rhs.size ? lhs : rhs
end

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

def manifests_hash
  hash = {}
  pulled = docker_images_pulled
  Dir.glob("#{path}/**/manifest.json").each do |filename|
    content = IO.read(filename)
    manifest = JSON.parse(content)
    display_name = manifest['display_name']
    image_name = manifest['image_name']
    $longest_display_name = max_size($longest_display_name, display_name)
    $longest_image_name = max_size($longest_image_name, image_name)
    hash[display_name] = {
      'image_name' => image_name,
      'pulled' => pulled.include?(image_name) ? 'yes' : 'no'
    }
  end
  hash
end

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

def type
  content = IO.read("#{path}/start_point_type.json")
  JSON.parse(content)['type']
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

if type == 'exercises'
  Dir.glob("#{path}/**/instructions").each do |filename|
    puts filename.split('/')[-2].sub('_', ' ')
  end
else
  hash = manifests_hash
  puts inspect_line(display_name_title, image_name_title, 'PULLED?')
  hash.sort.each do |display_name, property|
    puts inspect_line(display_name, property['image_name'], property['pulled'])
  end
end