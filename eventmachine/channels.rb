require 'eventmachine'

EM.run do
  channel = EventMachine::Channel.new

  EM.defer do
    channel.subscribe{|message| puts "thread 1: #{message}"}
  end

  EM.defer do
    subscription_id = channel.subscribe{|message| puts "thread 2: #{message}"}
    sleep 3
    channel.unsubscribe(subscription_id)
  end

  EM.add_periodic_timer(1) do
    channel << "Hello"
  end


end