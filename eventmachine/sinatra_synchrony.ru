require 'sinatra'

require 'sinatra/synchrony'

class App < Sinatra::Base
  register Sinatra::Synchrony

  get '/' do
    "hello world"
  end

end

run App

