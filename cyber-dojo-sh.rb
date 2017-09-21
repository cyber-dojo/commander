
def cyber_dojo_sh
  help = [
    '',
    "Use: #{me} sh [CONTAINER]",
    '',
    'Shells into the named cyber-dojo docker container',
    'Defaults to shelling into cyber-dojo-web container'

  ]

  if ARGV[1] == '--help'
    show help
    exit succeeded
  end

  if ARGV.size > 2
    show help
    exit failed
  end

  # cyber-dojo.sh does actual [sh]
end
