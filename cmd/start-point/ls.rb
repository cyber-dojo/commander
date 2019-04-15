
def cyber_dojo_start_point_ls
  exit_success_if_show_start_point_ls_help
  exit_failure_if_start_point_ls_unknown_arguments
  json = {}
  names = []
  ['custom','exercises','languages'].each do |type|
    cmd = 'docker image ls'
    cmd += " --filter 'label=org.cyber-dojo.start-point=#{type}'"
    cmd += " --format '{{.Repository}}:{{.Tag}}'"
    image_names = run(cmd).split
    if image_names != []
      json[type] = image_names
      names += image_names
    end
  end
  options = ARGV[2..-1]
  if options == ['--quiet'] || options == ['-q']
    puts names
  else
    puts JSON.pretty_generate(json)
  end
end

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

def exit_success_if_show_start_point_ls_help
  help = [
    '',
    "Use: #{me} start-point ls [-q|--quiet]",
    '',
    'Lists, in JSON form, the name and type of all cyber-dojo start-points.',
    '',
    '-q|--quiet     Only display start-point names'

  ]
  if ['-h','--help'].include?(ARGV[2])
    show help
    exit succeeded
  end
end

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

def exit_failure_if_start_point_ls_unknown_arguments
  return if ARGV[2..-1] == ['-q']
  return if ARGV[2..-1] == ['--quiet']
  ARGV[2..-1].each do |arg|
    STDERR.puts "FAILED: unknown argument [#{arg}]"
  end
  unless ARGV[2].nil?
    exit failed
  end
end
