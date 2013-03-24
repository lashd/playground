require 'playground/portal/helpers/http_operations'
require 'sinatra'

class Login < Sinatra::Base
  helpers Portal::Helpers::HttpOperations
  class << self
    attr_accessor :auth_url
  end

  helpers do
    def send_login_request
      http_post Login.auth_url, {credentials: {username: params[:username], password: params[:password]}}.to_json
    end
  end

  get '/' do
    haml :login
  end

  post '/' do
    result = send_login_request
    if result.status == 201
      token = JSON.parse(result.body)['token']
      response.set_cookie("auth_token", token)
      redirect "#{base_url}"
    else
      "failed login"
    end
  end
end