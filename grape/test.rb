require 'httparty'

puts HTTParty.get("http://localhost:9292/").code