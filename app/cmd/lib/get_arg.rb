
def get_arg(name, argv)
  # eg name: --custom
  #    argv: --custom=IMAGE
  #    ====> returns IMAGE
  args = argv.select{ |arg| arg.start_with?(name + '=')}.map{ |arg| arg.split('=')[1] || '' }
  args.size == 1 ? args[0] : nil
end
