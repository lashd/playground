require 'grape'
require 'playground/portal/helpers/memcache_operations'
require "em-synchrony/fiber_iterator"
require 'uuid'

class SessionService < Grape::API
  format :json
  helpers Portal::Helpers::MemcacheOperations

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
