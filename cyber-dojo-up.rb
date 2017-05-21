
def cyber_dojo_up
  help = [
    '',
    "Use: #{me} up [OPTIONS]",
    '',
    'Creates and starts the cyber-dojo server using named/default start-points',
    '',
    minitab + '--languages=START-POINT  Specify the languages start-point.',
    minitab + "                         Defaults to a start-point named 'languages' created from",
    minitab + '                         https://github.com/cyber-dojo/start-points-languages.git',
    '',
    minitab + '--exercises=START-POINT  Specify the exercises start-point.',
    minitab + "                         Defaults to a start-point named 'exercises' created from",
    minitab + '                         https://github.com/cyber-dojo/start-points-exercises.git',
    '',
    minitab + '--custom=START-POINT     Specify the custom start-point.',
    minitab + "                         Defaults to a start-point named 'custom' created from",
    minitab + '                         https://github.com/cyber-dojo/start-points-custom.git',
    '',
    minitab + '--port=LISTEN-PORT       Specify port to listen on.',
    minitab + "                         Defaults to 80"
  ]

  if ARGV[1] == '--help'
    show help
    exit succeeded
  end

  # unknown arguments?
  args = ARGV[1..-1]
  knowns = ['languages','exercises','custom','port']
  unknowns = args.select do |arg|
    knowns.none? { |known| arg.start_with?('--' + known + '=') }
  end
  unknowns.each do |unknown|
    arg = unknown.split('=')[0]
    STDERR.puts "FAILED: unknown argument [#{arg}]"
  end
  exit failed unless unknowns == []

  # explicit start-points?
  exit failed unless up_arg_ok(help, args, 'languages')  # --languages=NAME
  exit failed unless up_arg_ok(help, args, 'exercises')  # --exercises=NAME
  exit failed unless up_arg_ok(help, args,    'custom')  # --custom=NAME
  exit failed unless up_arg_int_ok(help, args,  'port')  # --port=PORT

  # cyber-dojo.sh does actual [up]
end

# - - - - - - - - - - - - - - - - - - - - - - - - -

def up_arg_int_ok(help, args, name)
  int_value = get_arg("--#{name}", args)
  if int_value.nil?
    return true
  end

  if int_value == ''
    STDERR.puts "FAILED: missing argument value --#{name}=[???]"
    return false
  end

  # TODO: validate that it's an int?

  return true
end

# - - - - - - - - - - - - - - - - - - - - - - - - -

def up_arg_ok(help, args, name)
  vol = get_arg("--#{name}", args)
  if vol.nil? || vol == name # handled in cyber-dojo.sh
    return true
  end

  if vol == ''
    STDERR.puts "FAILED: missing argument value --#{name}=[???]"
    return false
  end
  unless volume_exists?(vol)
    STDERR.puts "FAILED: start-point #{vol} does not exist"
    return false
  end
  type = cyber_dojo_type(vol)
  if type != name
    STDERR.puts "FAILED: #{vol} is not a #{name} start-point (it's type from setup.json is #{type})"
    return false
  end
  return true
end
