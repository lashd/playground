require 'sinatra'
require 'sinatra/synchrony'
require 'em-synchrony/em-memcache'

require 'hashie'
require 'rack/fiber_pool'

class MyMiddleWare
  def initialize app
    @app = app
  end

  def call env
    puts "called"
    @app.call env
  end
end

class App < Sinatra::Base
  use MyMiddleWare
  register Sinatra::Synchrony

  def connection
    EventMachine::Protocols::Memcache.connect
  end

  get '/' do
    connection.set("token", Marshal.dump({:name => "leon"}))

    connection.get("token")
  end
end

#use Rack::FiberPool
run App

