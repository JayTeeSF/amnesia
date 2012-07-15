$LOAD_PATH << File.dirname(__FILE__) + "/lib"

require 'rubygems'
require 'bundler/setup'
require './lib/amnesia.rb'

## This stops invalid US-ASCII characters on heroku.
#if defined? Encoding
#  Encoding.default_internal = 'utf-8' 
#  Encoding.default_external = 'utf-8'
#end

# setup tunnel to production & staging memcached:
children = []
[ {:host => "209.251.186.20", :user => 'iminds', :remote_port => "11211", :local_port => "11212", :name => "prod", :ssh_port => "7009"},
  {:host => "72.46.238.166",  :user => 'iminds',:remote_port => "11211", :local_port => "11213", :name => "staging", :ssh_port => "7015"} ].each do |config|
  cmd = "(ssh -f -N -L #{config[:local_port]}:127.0.0.1:#{config[:remote_port]} -p #{config[:ssh_port]} iminds@#{config[:host]}) &"
  puts "attempting to open tunnel: #{cmd}..."
  children << fork do
    %x/#{cmd}/
  end
end

use Amnesia::Application, :hosts => ['localhost:11211', 'localhost:11212', 'localhost:11213']
run Sinatra::Application
