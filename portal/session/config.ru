require "#{File.dirname(__FILE__)}/lib/session_service"
require 'cloudfoundry/environment'
require 'rack/fiber_pool'

puts "RACK_ENV is: #{ENV['RACK_ENV']}"


case ENV['RACK_ENV']
  when 'local:integration'
    Portal::Memcache.host= "172.16.243.252:11211"
  else
    Portal::Memcache.host= "localhost:11211"
end
use Rack::FiberPool
run SessionService