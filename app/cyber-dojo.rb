#!/usr/bin/env ruby

# Called from cyber-dojo-inner

require_relative 'help'
require_relative 'lib/all'
require_relative 'start-point/all'
require_relative 'server/all'
require_relative 'service/all'
require 'json'
require 'tempfile'

$exit_status = 0

if ARGV[0] === '--debug'
  $debug_on = true
  ARGV.shift
else
  $debug_on = false
end

if ARGV[0] === '--on_mac'
  $on_mac = true
  ARGV.shift
else
  $on_mac = false
end

case ARGV[0]
  when nil            then cyber_dojo_help
  when '-h'           then cyber_dojo_help
  when '--help'       then cyber_dojo_help
  when 'clean'        then cyber_dojo_server_clean
  when 'down'         then cyber_dojo_server_down
  when 'logs'         then cyber_dojo_service_logs
  when 'start-point'  then cyber_dojo_start_point
  when 'up'           then cyber_dojo_server_up
  when 'update'       then cyber_dojo_server_update
  when 'version'      then cyber_dojo_server_version
  else
    STDERR.puts "ERROR: unknown argument [#{ARGV[0]}]"
    exit failed
end

exit 0
