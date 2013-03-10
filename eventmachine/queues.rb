require 'eventmachine'

EM.run do
  q = EM::Queue.new

  EM.defer do
    q.push(1)
    sleep 1
    q.push(2)
    sleep 1
    q.push(3)
    sleep 1
  end

  3.times{q.pop{|item| puts item}}
end