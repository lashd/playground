require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/synchrony'

require 'faraday'

class App < Sinatra::Base
  register Sinatra::Synchrony
  #register Sinatra::Reloader


  get '/' do

    # This request is running in a fiber which will be paused by em-syncrony/em-http when
    # the initial call goes out and whilst a the response from google.com comes back.
    # When it comes back the fibre is resumed and event machine can continue to serve other requests?
    connection = Faraday.new do |builder|
      builder.use Faraday::Adapter::EMSynchrony
    end
    result = connection.get "http://google.com"

    result.body
  end

end

run App

