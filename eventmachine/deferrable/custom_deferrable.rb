require 'eventmachine'

class Order
  include EventMachine::Deferrable

  def my_function succeed
    if succeed
      set_deferred_status :succeeded
    else
      set_deferred_status :failed
    end
  end
end

EM.run do
  order1 = Order.new
  order2 = Order.new

  order1.callback{puts "Order 1: succeeded"}
  order1.errback{puts "Order 1: failed"}
  order2.callback{puts "Order 2: succeeded"}
  order2.errback{puts "Order 2: failed"}

  order1.my_function false
  order2.my_function true

end
