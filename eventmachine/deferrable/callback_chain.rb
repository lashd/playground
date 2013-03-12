require 'eventmachine'

EM.run do
  deferrable = EventMachine::DefaultDeferrable.new

  deferrable.callback do |name|
    class_name = "deferrables"
    puts "#{name} completed: #{class_name}"
    deferrable.succeed(name, class_name)
  end

  deferrable.callback do |name, class_name|
    puts "adding #{class_name} to #{name}'s record"

    deferrable.succeed
  end

  deferrable.callback{EM.stop}

  EM.add_timer(2) do
    deferrable.succeed("Leon")
  end
end