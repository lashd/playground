require 'eventmachine'

EM.run do
  deferrable = EventMachine::DefaultDeferrable.new

  deferrable.callback{|arg| puts "success: #{arg}"}
  deferrable.errback{puts "failed"}

  EM.add_timer(2) do
    deferrable.succeed("Leon")
  end
end