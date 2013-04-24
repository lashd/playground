require 'nokogiri'
require 'handsoap'
require 'eventmachine'
require 'mirage/client'
require 'nokogiri'

module Handsoap
  module Http

    # Represents a HTTP Request.
    class Request
      def add_header(key, value)
        @headers[key] = value
      end
    end
  end
end


client = Mirage.start

client.put("greeting", "greeting") do |response|
  response.method = :post
end

EXAMPLE_SERVICE_ENDPOINT = {
    :uri => "http://wsf.cdyne.com/WeatherWS/Weather.asmx",
    :version => 1
}

Handsoap.http_driver = :event_machine


class WeatherServiceClient < Handsoap::Service
  endpoint EXAMPLE_SERVICE_ENDPOINT

  on_create_document do |doc|
    doc.alias 'weat', "http://ws.cdyne.com/WeatherWS"
  end

  def get_weather postcode, &block
    async(block) do |dispatcher|
      dispatcher.request("GetCityWeatherByZIP",:soap_action =>  "http://ws.cdyne.com/WeatherWS/GetCityWeatherByZIP") do |m|
        m.add "weat:ZIP", postcode
      end

      dispatcher.response do |response|
        puts "response: #{response.http_response.body}"
        response.http_response.body
      end
    end
  end

end

EventMachine.run do

  client = WeatherServiceClient.new

  client.get_weather(90210) do |d|

    d.callback do |text|
      doc = Nokogiri::XML(text)
      puts doc
      EventMachine.stop
    end

    d.errback do |mixed|
      puts "Flunked![#{mixed}]"
      EventMachine.stop
    end
  end


end


#require 'savon'
#client = Savon.client do
#  wsdl "http://wsf.cdyne.com/WeatherWS/Weather.asmx?wsdl"
#end
#client.call(:get_city_weather_by_zip, :message => {:zip => 90210})