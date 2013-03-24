require "#{File.dirname(__FILE__)}/lib/session_service"
require 'cloudfoundry/environment'
require 'rack/fiber_pool'

Portal::Memcache.host= "localhost"

use Rack::FiberPool
run SessionService