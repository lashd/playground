require 'eventmachine'
require 'sinatra'
require 'rack/fiber_pool'


class ServiceNowCall
  include EventMachine::Deferrable

  def on_success &block
    return @on_success unless block
    @on_success = block
    self.callback &block
  end

  def on_fail &block
    return @on_fail unless block
    @on_fail = block
    self.errback &block
  end

  def initialize
    self.errback do |count|
      if count < 5
        EM.add_timer(0.1) do
          puts "retrying: #{count}"
          new_call = self.class.new
          new_call.on_success &on_success
          new_call.on_fail &on_fail

          new_call.make_call(count + 1)
        end
      else
        on_fail.call
      end
    end
  end

  def make_call try=0, &block
    result = rand(9999)%2
    result == 0 ? succeed(try) : fail(try)
  end
end

class App < Sinatra::Base

  get '/' do
    service_now_call = ServiceNowCall.new

    service_now_call.on_success do
      env['async.callback'].call [200, {}, "wooop"]
    end
    service_now_call.on_fail do
      env['async.callback'].call [500, {}, ":("]
    end

    service_now_call.make_call

    :async
  end
end

use Rack::FiberPool

run App