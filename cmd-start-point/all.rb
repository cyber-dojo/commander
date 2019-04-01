
require_relative 'create'
require_relative 'inspect'
require_relative 'latest'
require_relative 'ls'
require_relative 'pull'
require_relative 'rm'

def cyber_dojo_start_point
  help = [
    '',
    "Use: #{me} start-point [COMMAND]",
    '',
    'Manage cyber-dojo start-point images',
    '',
    'Commands:',
    minitab + 'create         Creates a new start-point',
    minitab + 'inspect        Displays details of a start-point',
    minitab + 'latest         Updates pulled docker images named inside a start-point',
    minitab + 'ls             Lists the names of all start-points',
    minitab + 'pull           Pulls all the docker images named inside a start-point',
    minitab + 'rm             Removes a start-point',
    '',
    "Run '#{me} start-point COMMAND --help' for more information on a command",
  ]

  if [nil,'-h','--help'].include? ARGV[1]
    show help
    exit succeeded
  end

  case ARGV[1]
    when 'create'  then cyber_dojo_start_point_create
    when 'inspect' then cyber_dojo_start_point_inspect
    when 'latest'  then cyber_dojo_start_point_latest
    when 'ls'      then cyber_dojo_start_point_ls
    when 'pull'    then cyber_dojo_start_point_pull
    when 'rm'      then cyber_dojo_start_point_rm
    else begin
      ARGV[1..-1].each do |arg|
        STDERR.puts "FAILED: unknown argument [#{arg}]"
      end
      exit failed
    end
  end
end
