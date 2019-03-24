
def cyber_dojo_start_points_ls
  help = [
    '',
    "Use: #{me} start-points [OPTIONS] ls",
    '',
    'Lists the name, type, and git-repo-url source of all cyber-dojo start-points images',
    '',
    minitab + '--quiet     Only display start-points image names'
  ]

  if ARGV[2] == '-h' || ARGV[2] == '--help'
    show help
    exit succeeded
  end

  types = ['custom','exercises','languages']
  types.each do |type|
    cmd = 'docker image ls'
    cmd += " --filter 'label=org.cyber-dojo.start-points=#{type}'"
    cmd += " --format '{{.Repository}}:{{.Tag}}'"
    run(cmd).split.each do |name|
      puts "--#{type}\t#{name}"
    end
  end

  # TODO: non-quiet
  # names = names.select{ |name| cyber_dojo_volume?(name) }

=begin
  if ARGV[2] == '--quiet'
    names.each { |name| puts name }
  else

    ARGV[2..-1].each do |arg|
      STDERR.puts "FAILED: unknown argument [#{arg}]"
    end
    unless ARGV[2].nil?
      exit failed
    end

    types = names.map { |name| cyber_dojo_type(name)  }
    urls  = names.map { |name| cyber_dojo_label(name) }

    headings = { :name => 'NAME', :type => 'TYPE', :url => 'SRC' }

    gap = 3
    max_name = ([headings[:name]] + names).max_by(&:length).length + gap
    max_type = ([headings[:type]] + types).max_by(&:length).length + gap
    max_url  = ([headings[:url ]] + urls ).max_by(&:length).length + gap

    spacer = lambda { |max,s| s + (space * (max - s.length)) }

    name = spacer.call(max_name, headings[:name])
    type = spacer.call(max_type, headings[:type])
    url  = spacer.call(max_url , headings[:url ])
    unless names.empty?
      puts name + type + url
    end
    names.length.times do |n|
      name = spacer.call(max_name, names[n])
      type = spacer.call(max_type, types[n])
      url  = spacer.call(max_url ,  urls[n])
      puts name + type + url
    end
  end
=end
end
