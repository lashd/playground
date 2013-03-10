require 'eventmachine'

class EchoClient < EM::Connection

  def initialize user
    @user = user
  end

  def post_init
    puts "Connected"
    send_data "hello from #{@user}"
  end

  def unbind
    puts "disconnected"
  end

  def receive_data data
    puts "received: #{data}"
    close_connection
    EM.stop
  end

end

EM.run do
  user = ARGV[0]
  EM.connect('localhost', 9000, EchoClient, ARGV[0])
end