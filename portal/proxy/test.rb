require 'rubygems'
require 'eventmachine'
require 'em-http'
require 'json'

urls = ['http://localhost:3001/']
if urls.size < 1
  puts "Usage: #{$0} <url> <url> <...>"
  exit
end

pending = urls.size

EM.run do
  urls.each do |url|
    json = {credentials: {username: "Bruce", password: "Arkham"}}.to_json
    #http = EM::HttpRequest.new("http://localhost:3001").post(:body => json, :head => {"content-type" => "application/json"})
    #http.callback {
    #  p http.response_header.status
    #  p http.response_header
    #  p http.response
    #
    #  [http.response_header.status, {}, http.response]
    #}
    #http.errback {
    #  puts "fail!"
    #  puts http.response
    #  puts http.response_header.status
    #}

    http = EM::HttpRequest.new(url).post(:body => json, :head => {"content-type" => "application/json"})
    http.callback {
      puts "#{url}\n#{http.response_header.status} - #{http.response.length} bytes\n"
      puts http.response

      pending -= 1
      EM.stop if pending < 1
    }
    http.errback {
      puts "#{url}\n" + http.error

      pending -= 1
      EM.stop if pending < 1
    }
  end
end