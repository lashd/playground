require 'grape'
require 'rack/fiber_pool'
require 'em-synchrony/em-memcache'
class SessionService < Grape::API
  format :json

  helpers do
    def memcache
      EventMachine::Protocols::Memcache.connect
    end
  end
  put "/:token" do
    fiber = Fiber.new do
      memcache.set(params[:token], "a value")
    end
    fiber.resume

    {status: "ok"}
  end

  get "/:token" do
    result = memcache.get(params[:token])
    throw(:error, :status => 404) unless result
  end
end

use Rack::FiberPool
map "/session" do
  run SessionService
end
