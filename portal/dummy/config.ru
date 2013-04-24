require 'sinatra'
require 'cloudfoundry/environment'

class DummyApp < Sinatra::Base
  get '/' do
    "hello world"
  end
end

run DummyApp