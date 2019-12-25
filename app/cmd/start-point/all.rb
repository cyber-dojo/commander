require_relative 'create'
require_relative 'inspect'
require_relative 'ls'
require_relative 'rm'
require_relative 'update'

# - - - - - - - - - - - - - - - - - - - - - - - -

def cyber_dojo_start_point
  exit_success_if_show_start_point_help
  command = ARGV[1]
  case command
    when 'create'  then cyber_dojo_start_point_create
    when 'inspect' then cyber_dojo_start_point_inspect
    when 'ls'      then cyber_dojo_start_point_ls
    when 'rm'      then cyber_dojo_start_point_rm
    when 'update'  then cyber_dojo_start_point_update
    else begin
      ARGV[1..-1].each do |arg|
        STDERR.puts "ERROR: unknown argument [#{arg}]"
      end
      exit(failed)
    end
  end
end

# - - - - - - - - - - - - - - - - - - - - - - - -

def exit_success_if_show_start_point_help
  minitab = ' ' * 2
  help = [
    '',
    "Use: #{me} start-point [COMMAND]",
    '',
    'Manage cyber-dojo start-points',
    '',
    'Commands:',
    minitab + 'create         Creates a new start-point from a list of git-repo urls',
    minitab + 'inspect        Displays details of a named start-point',
    minitab + 'ls             Lists the names of all start-points',
    minitab + 'rm             Removes a named start-point',
    minitab + 'update         Updates all the docker images inside a named start-point',
    '',
    'For more information on a command run:',
    "  #{me} start-point COMMAND --help"
  ]
  command = ARGV[1]
  if [nil,'-h','--help'].include?(command)
    show help
    exit succeeded
  end
end
