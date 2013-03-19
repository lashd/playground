require 'sinatra'
require 'sinatra/synchrony'
require "em-synchrony/em-http"
require "em-synchrony/fiber_iterator"
require 'await'


class App < Sinatra::Base
  register Sinatra::Synchrony

  helpers do
    def sleep time
      fiber = Fiber.current
      EM.add_timer(time) do
        fiber.resume
      end
      Fiber.yield
    end
  end

  get '/' do
    time = Time.now
    sleep 3
    "That took: #{Time.now - time}"
  end

end

run App