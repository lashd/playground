require 'sinatra'
require 'grape'
require 'uuid'
require 'faraday'
require 'json'
require 'haml'
require 'eventmachine'
require 'playground/portal/helpers/memcache_operations'
require 'em-synchrony/em-memcache'
require 'em-synchrony/em-http'
require 'em-synchrony'
require "em-synchrony/fiber_iterator"
require 'rack/fiber_pool'
require 'hashie'

module HttpOperations
  def http
    Faraday.new do |connection|
      connection.use Faraday::Adapter::EMSynchrony
    end
  end

  def http_post url, body="", content_type="application/json"
    http.post(url) do |request|
      request.body = body if body
      request.headers['Content-Type'] = content_type
    end
  end

  def http_put url, body = nil
    http.put(url) do |request|
      request.body = body if body
    end
  end

  def http_get url, params={}
    http.get(url, params)
  end
end

class Authentication
  include HttpOperations

  def login_url url=nil
    return @login_url unless url
    @login_url = url
  end

  def authentication_service_url url=nil
    return @authentication_service_url unless url
    @authentication_service_url = url
  end

  def initialize app
    @app = app
    @application = app.class.name
    yield self if block_given?
  end

  def logged_in(authorisation_token)
    http_get("#{authentication_service_url}/#{authorisation_token}", :application => @application).status == 200
  end

  def call env
    authorisation_token = request(env).cookies['auth_token']

    if logged_in(authorisation_token)
      @app.call env
    else
      [301, {"Location" => login_url, "Content-Type" => "text/html"}, []]
    end

  end

  def request env
    Rack::Request.new(env)
  end
end

class SessionManagement
  include HttpOperations
  include MemcacheOperations

  module SessionMethods
    def session
      @session ||= @env["session_management.session"]
    end
  end

  def session_service_url url=nil
    return @session_service_url unless url
    @session_service_url = url
  end

  def initialize(app)
    @app = app
    yield self if block_given?
    @app.class.send(:include, SessionMethods)
  end

  def request env
    Rack::Request.new(env)
  end

  def call(env)
    authorisation_token = request(env).cookies['auth_token']
    app_token = "#{authorisation_token}_#{@app.class.name}"

    session_url = "#{session_service_url}/#{authorisation_token}/#{app_token}"

    register_application_session(session_url) unless application_session_registered?(session_url)

    load_session(app_token, env)
    result = @app.call(env)
    save_session(app_token, env)
    result
  end

  def save_session(app_token, env)
    set_in_cache(app_token, env["session_management.session"])
  end

  def register_application_session(session_url)
    http_put(session_url)
  end

  def application_session_registered?(session_url)
    http_get(session_url).status == 200
  end

  def load_session(app_token, env)
    env["session_management.session"] = begin
      get_from_cache app_token
    rescue
      {}
    end
  end
end


module UrlBuilder
  def base_url
    "#{request.scheme}://#{request.host}:#{request.port}"
  end
end

class Login < Sinatra::Base
  helpers HttpOperations, UrlBuilder
  helpers do
    def send_login_request
      http_post "#{base_url}/auth", {credentials: {username: params[:username], password: params[:password]}}.to_json
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



class SessionService < Grape::API
  format :json
  helpers MemcacheOperations

  put "/:token/:app_token" do
    cache_entry = get_from_cache(params[:token])
    cache_entry << params[:app_token]
    set_in_cache(params[:token], cache_entry)
    {status: "ok"}
  end

  get "/:token/:app_token" do
    token = params[:token]
    cache_entry = get_from_cache(token)
    throw(:error, :status => 404) unless cache_entry
    throw(:error, :status => 404) unless cache_entry.include?(params[:app_token])
  end

  post "/" do
    token = UUID.generate(:compact)
    set_in_cache(token, [])
    {token: token}
  end

  post "/:token" do
    token = params[:token]
    module_sessions = get_from_cache(token)
    throw(:error, :status => 404) unless module_sessions

    set_in_cache(token, module_sessions)

    EM::Synchrony::FiberIterator.new(module_sessions, 10).each do |tracked_token|
      puts "refreshing: #{tracked_token}"
      set_in_cache(tracked_token, get_from_cache(tracked_token))
    end
  end
end


class HomePage < Sinatra::Base

  use Authentication do |config|
    config.login_url "http://localhost:3000/login"
    config.authentication_service_url "http://localhost:3000/auth"
  end

  use SessionManagement do |config|
    config.session_service_url "http://localhost:3000/sessions"
  end

  get '/' do
    puts "value out of the session: #{session[:name]}"
    session[:name] = "homepage_value"
    haml :home
  end
end

class Procure < Sinatra::Base

  use Authentication do |config|
    config.login_url "http://localhost:3000/login"
    config.authentication_service_url "http://localhost:3000/auth"
  end

  use(SessionManagement) do |config|
    config.session_service_url "http://localhost:3000/sessions"
  end

  get '/' do
    puts "value out of the session: #{session[:name]}"
    session[:name] = "procure_value"
    haml :procure
  end
end

use Rack::FiberPool

map "/login" do
  run Login
end

map "/procure" do
  run Procure
end

map "/auth" do
  run AuthenticationService
end

map "/sessions" do
  run SessionService
end

map "/" do
  run HomePage
end