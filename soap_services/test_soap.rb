require 'savon'
require 'eventmachine'
require 'em-http-request'

module Savon
  class Operation
    def http
      Faraday.new do |connection|
        connection.use Faraday::Adapter::EMSynchrony
      end
    end

    def create_request locals, &block
      @locals = LocalOptions.new(locals)

      BlockInterface.new(@locals).evaluate(block) if block

      builder = Builder.new(@name, @wsdl, @globals, @locals)

      Savon.notify_observers(@name, builder, @globals, @locals)
      build_request(builder)
    end

    def call! request

      http = EventMachine::HttpRequest.new(request.url.to_s).post

      http.callback do |response|
        HTTPI::Response.new(response.status, response.headers.to_hash, response.body)
      end

      http.errback do

      end

      #response = http.post(request.url.to_s) do |faraday_request|
      #  request.headers.to_hash.each { |header, value| faraday_request.headers[header] = value }
      #  faraday_request.body = request.body
      #end

      HTTPI::Response.new(response.status, response.headers.to_hash, response.body)
    end
  end
end

#class App < Sinatra::Base
#  #register Sinatra::Synchrony
#  get '/' do
#    puts "receiving request"
#    content_type "text/plain"
#    client = Savon.client do
#      wsdl "/home/team/Projects/playground/soap_services/Weather.wsdl"
#    end
#
#    client.call(:get_city_weather_by_zip, :message => {:zip => 90210}).body
#  end
#end
EventMachine.run do
  client = Savon.client do
    wsdl "/home/team/Projects/playground/soap_services/Weather.wsdl"
  end

  request = client.operation(:get_city_weather_by_zip).create_request(:message => {:zip => 90210})
  puts request.body

  puts "hello"
  http = EventMachine::HttpRequest.new("http://wsf.cdyne.com/WeatherWS/Weather.asmx").post :body => request.body, :head => request.headers.to_hash
  puts "goodbye"

  http.callback do |response|
    puts "Pass"
    puts response
    EventMachine.stop
  end

  http.errback do |response|
    puts "Fail"
    puts response
    EventMachine.stop
  end
  puts "goodbye"
end
