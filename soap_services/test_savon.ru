require 'savon'
require 'sinatra'
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
  end
end

$client = Savon.client do
  wsdl "/home/team/Projects/playground/soap_services/Weather.wsdl"
end

class App < Sinatra::Base
  get '/' do
    puts "receiving request"


    $client = Savon.client do
      wsdl "/home/team/Projects/playground/soap_services/Weather.wsdl"
    end

    request = $client.operation(:get_city_weather_by_zip).create_request(:message => {:zip => 90210})

    http = EventMachine::HttpRequest.new("http://wsf.cdyne.com/WeatherWS/Weather.asmx").post :body => request.body, :head => request.headers.to_hash

    http.callback do |response|
      puts "Pass"
      env['async.callback'].call [200, {}, response.response]
      puts response
    end

    http.errback do |response|
      puts "Fail"
      puts response
    end

    puts "here"
    [-1, {}, '']
  end
end

run App
