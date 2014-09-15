# encoding: utf-8

require 'bunny'

connection = Bunny.new
connection.start
channel = connection.create_channel

n = ARGV[0].to_i
msg = ARGV[1]

exchange = channel.direct('work.to.do', durable: true)
channel.queue_bind('my_queue', 'work.to.do')

n.times do |ix|
  exchange.publish("#{ix}: " + msg)
end
