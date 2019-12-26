
def env_file_to_h(src)
  lines = src.lines.reject do |line|
    line.start_with?('#') || line.strip.empty?
  end
  lines.map{ |line| line.split('=').map(&:strip) }.to_h
end
