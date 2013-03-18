require 'dalli'
require 'hashie'
client = Dalli::Client.new
client.set("token", Hashie::Mash.new)
puts client.get("65a200d0716c0130fe12000c290db823")
