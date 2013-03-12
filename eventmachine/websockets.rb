require 'eventmachine'
require 'em-websocket'


EventMachine.run do
  EM::WebSocket.start(:host => "0.0.0.0", :port => 8080) do |ws|
    ws.onopen{puts "client connected"}
    ws.onerror{|e| puts "error occurred: #{e.message}"}
    ws.onclose{puts "connection closed"}
  end
end