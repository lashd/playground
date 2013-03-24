require "#{File.dirname(__FILE__)}/lib/login_application"
require 'cloudfoundry/environment'
require 'ext/cloudfoundry/environment'
require 'rack/fiber_pool'

class Login < Sinatra::Base
  configure("development:integration".to_sym) do
    Login.auth_url= "http://auth.#{CloudFoundry::Environment.root_domain}"
  end

  configure(:development) do
    Login.auth_url= "http://localhost"
  end
end

use Rack::FiberPool
run Login