
def cyber_dojo_help
  tab = ' ' * 4
  puts [
    '',
    "Use: #{me} [--debug] COMMAND",
    "     #{me} --help",
    '',
    'Commands:',
    tab + 'clean        Removes old images/volumes/containers',
    tab + 'down         Brings down the server',
    tab + 'logs         Prints the logs from a service container',
    tab + 'sh           Shells into a service container',
    tab + 'start-point  Manages cyber-dojo start-points',
    tab + 'up           Brings up the server',
    tab + 'update       Updates the server to latest or to a given version',
    tab + 'version      Displays the current version',
    '',
    "Run '#{me} COMMAND --help' for more information on a command."
  ].join("\n") + "\n"
end
