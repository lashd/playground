require 'sinatra'
require 'sinatra/synchrony'
require "em-synchrony/em-http"
require "em-synchrony/fiber_iterator"
require 'faraday'
require 'rack/fiber_pool'


class App < Sinatra::Base
  class << self
    def http
      @http ||= Faraday.new do |connection|
        connection.use Faraday::Adapter::EMSynchrony
      end
    end
  end
  #register Sinatra::Synchrony

  helpers do
    def http
      App.http
    end
  end

  get '/update' do
    urls = []
    10.times { urls << "http://localhost:3001/" }

    concurrency = 5
    EM::Synchrony::FiberIterator.new(urls, concurrency).each do |url|
      fiber = Fiber.new do
        result = http.get(url)
        puts result.body
      end
      fiber.resume

    end

    "cash being updated"
  end


end

use Rack::FiberPool
run App