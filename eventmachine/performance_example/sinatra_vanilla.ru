require 'sinatra'
require 'sinatra/reloader'
require 'faraday'

class App < Sinatra::Base
  get '/' do
    result = Faraday.get("http://www.google.com")
    "Search results for: #{result.body}"
  end
end

run App