require 'rack/fiber_pool'
require 'em-http'
require 'json'
require 'rack/utils'
require 'rack/commonlogger'
require 'cloudfoundry/environment'
require 'ext/cloudfoundry/environment'


class Proxy
  ASYNC_RESPONSE = [-1, {}, ""]

  class << self
    attr_accessor :session_service_host, :auth_service_host, :login_app_host
  end

  def extract_http_request_headers(env)
    headers = env.reject do |k, v|
      !(/^HTTP_[A-Z_]+$/ === k) || v.nil?
    end.map do |k, v|
      [reconstruct_header_name(k), v]
    end.inject(Rack::Utils::HeaderHash.new) do |hash, k_v|
      k, v = k_v
      hash[k] = v
      hash
    end

    x_forwarded_for = (headers["X-Forwarded-For"].to_s.split(/, +/) << env["REMOTE_ADDR"]).join(", ")

    headers.merge!("X-Forwarded-For" => x_forwarded_for)
  end

  def reconstruct_header_name(name)
    name.sub(/^HTTP_/, "").gsub("_", "-")
  end

  def call env
    requested_path = env['REQUEST_URI'].chomp.strip
    url = resolve_url(requested_path)
    if url
      request = Rack::Request.new(env)
      url << request.path.gsub(/^#{requested_path}/, "") << request.query_string

      headers = extract_http_request_headers(env)
      headers["content-type"] = request.content_type if request.content_type
      headers["Content-Type"] = request.content_type if request.content_type

      options = {:head => headers}
      options[:body] = request.body.read

      http = EM::HttpRequest.new(url).method(request.request_method.downcase.to_sym).call(options)

      http.callback {
        env['async.callback'].call [http.response_header.status, http.response_header.to_hash, http.response]
      }
      http.errback {
        puts "#{requested_path}: fail!"
      }

      return ASYNC_RESPONSE
    end
    [404, {}, "route undefined"]
  end

  def resolve_url(requested_path)
    case requested_path
      when '/auth'
        Proxy.auth_service_host
      when '/sessions'
        Proxy.session_service_host
      when '/login'
        Proxy.login_app_host
    end
  end

end

puts "RACK_ENV= #{ENV['RACK_ENV']}"

case ENV['RACK_ENV'] || 'development'
  when 'thingy'
    Proxy.auth_service_host= "http://localhost:3001/"
    Proxy.session_service_host= "http://localhost:3002/"
    Proxy.login_app_host = "http://localhost:3003"
  when 'development:integration'
    cloud_foundry_domain = CloudFoundry::Environment.root_domain
    Proxy.session_service_host= "http://session.#{cloud_foundry_domain}/"
    Proxy.auth_service_host= "http://auth.#{cloud_foundry_domain}/"
    Proxy.login_app_host = "http://login_app.#{cloud_foundry_domain}/"
end

use Rack::CommonLogger, $stdout
run Proxy.new