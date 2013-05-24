#require 'sinatra'

class HomePage < Sinatra::Base
  def logged_in?
    false
  end

  before '/' do
    redirect '/not_logged_in' unless logged_in?
  end

  get '/' do
    'The home page'
  end

  get '/not_logged_in' do
    'you are not logged in!'
  end
end

class Authentication
  def initialize app,*args, &block

    @app = app
    yield
    puts "the login url will be: #{@url}"
  end

  def login_url url
    @url = url
  end

  def call env

    puts "middleware called!!!!"
    @app.call env
  end
end

class MyCustomApp
  def call env
    [200, {}, ['my custom app!']]
  end
end


use Authentication {login_url 'http://login.url'}
use Authentication {login_url 'http://login.url'}

run MyCustomApp.new