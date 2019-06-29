
require_relative 'dot_env'
require_relative 'env_file_to_h'
require_relative 'get_arg'
require_relative 'image_exists'
require_relative 'run'
require_relative 'start_point_image'

def succeeded; 0; end

def failed; 1; end

def me; 'cyber-dojo'; end

def show(lines); lines.each { |line| puts line }; print "\n"; end
