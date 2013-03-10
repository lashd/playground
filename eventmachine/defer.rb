require 'eventmachine'

EM.run do
  operation = Proc.new do
    rand(99999)
  end

  callback = Proc.new do |result|
    puts "result was #{result}"
  end

  EM.defer operation, callback
end