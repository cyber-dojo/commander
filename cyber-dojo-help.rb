
def cyber_dojo_help
  puts [
    '',
    "Use: #{me} [--debug] COMMAND",
    "     #{me} --help",
    '',
    'Commands:',
    tab + 'clean        Removes old images/volumes/containers',
    tab + 'down         Brings down the server',
    tab + 'logs         Prints the logs from the server',
    tab + 'sh           Shells into the server',
    tab + 'start-point  Manages cyber-dojo start-points',
    tab + 'up           Brings up the server',
    tab + 'update       Updates the server and/or languages to the latest images',
    '',
    "Run '#{me} COMMAND --help' for more information on a command."
  ].join("\n") + "\n"
end

