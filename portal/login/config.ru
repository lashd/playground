require "#{File.dirname(__FILE__)}/lib/login_application"
require 'cloudfoundry/environment'
require 'ext/cloudfoundry/environment'
require 'rack/fiber_pool'

class Login < Sinatra::Base
  configure do
    set :root, File.dirname(__FILE__)
  end

  configure("development:integration".to_sym) do
    Login.auth_url= "http://application.#{CloudFoundry::Environment.root_domain}/auth"
  end

  configure(:development) do
    Login.auth_url= "http://localhost:3000/auth"
  end
end

use Rack::FiberPool
run Login