
require_relative 'cyber-dojo-start-points-create'
require_relative 'cyber-dojo-start-points-inspect'
require_relative 'cyber-dojo-start-points-latest'
require_relative 'cyber-dojo-start-points-ls'
require_relative 'cyber-dojo-start-points-pull'
require_relative 'cyber-dojo-start-points-rm'

def cyber_dojo_start_points
  help = [
    '',
    "Use: #{me} start-points [COMMAND]",
    '',
    'Manage cyber-dojo start-points images',
    '',
    'Commands:',
    minitab + 'create         Creates a new start-points image',
    minitab + 'inspect        Displays details of a start-points image',
    minitab + 'latest         Updates pulled docker images named inside a start-point',
    minitab + 'ls             Lists the names of all start-points images',
    minitab + 'pull           Pulls all the docker images named inside a start-points image',
    minitab + 'rm             Removes a start-points image',
    '',
    "Run '#{me} start-points COMMAND --help' for more information on a command",
  ]

  if [nil,'-h','--help'].include? ARGV[1]
    show help
    exit succeeded
  end

  case ARGV[1]
    when 'create'  then cyber_dojo_start_points_create
    when 'inspect' then cyber_dojo_start_points_inspect
    when 'latest'  then cyber_dojo_start_points_latest
    when 'ls'      then cyber_dojo_start_points_ls
    when 'pull'    then cyber_dojo_start_points_pull
    when 'rm'      then cyber_dojo_start_points_rm
    else begin
      ARGV[1..-1].each do |arg|
        STDERR.puts "FAILED: unknown argument [#{arg}]"
      end
      exit(failed)
    end
  end
end
