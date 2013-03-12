require 'eventmachine'

EventMachine.run do
  EventMachine.start_server("/tmp/server", nil) do |server|
    def server.receive_data data
      puts "received: #{data}"
    end
  end

  EventMachine.connect_unix_domain("/tmp/server") do |connection|
    connection.send_data("Hello")
  end
end