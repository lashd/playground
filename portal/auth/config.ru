require "#{File.dirname(__FILE__)}/lib/authentication_service"
require 'cloudfoundry/environment'
require 'rack/fiber_pool'

def services_domain
  CloudFoundry::Environment.host[/\w+\.(.*)/,1]
end

case ENV['RACK_ENV']
  when 'local:integration'
    AuthenticationService.session_service_url = "session.#{services_domain}"
  else
    AuthenticationService.session_service_url = "http://localhost"
end
use Rack::FiberPool
run AuthenticationService
