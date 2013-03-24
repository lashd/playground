require "#{File.dirname(__FILE__)}/lib/authentication_service"
require 'cloudfoundry/environment'
require 'ext/cloudfoundry/environment'
require 'rack/fiber_pool'

case ENV['RACK_ENV']
  when 'development:integration'
    AuthenticationService.session_service_url = "http://session.#{CloudFoundry::Environment.root_domain}"
  else
    AuthenticationService.session_service_url = "http://localhost"
end

puts "Session service url: #{AuthenticationService.session_service_url}"
use Rack::FiberPool

run AuthenticationService