require 'faraday'
require 'em-synchrony/em-http'
module Portal
  module Helpers
    module HttpOperations
      def http
        Faraday.new do |connection|
          connection.use Faraday::Adapter::EMSynchrony
        end
      end

      def http_post url, body="", content_type="application/json"
        http.post(url) do |request|
          request.body = body
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
  end
end
