
def run(command)
  output = `#{command}`
  $exit_status = $?.exitstatus
  if $debug_on
    STDERR.puts command
    puts $exit_status
    STDERR.puts output
  end
  output
end
