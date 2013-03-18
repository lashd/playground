require 'httparty'
puts HTTParty.get("http://localhost:3000/update").body

#fiber = Fiber.new do |some_value|
#  puts some_value
#  some_value = Fiber.yield "damn"
#  puts some_value
#end
#
#value = fiber.resume "hello"
#puts value
#fiber.resume "world"