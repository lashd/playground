require 'eventmachine'

class EchoServer < EM::Connection
  def post_init
    puts "Client connecting"
  end

  def unbind
    puts "Client disconnecting"
  end

  def receive_data data
    puts "received data: #{data}"
    send_data ">> #{data}"
  end
end

EM.run do
  EM.start_server("0.0.0.0", 9000, EchoServer)
end