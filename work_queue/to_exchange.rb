# encoding: utf-8

require 'bunny'

connection = Bunny.new
connection.start
channel = connection.create_channel

msg = ARGV[0] || 'Hi! What\'s up?'

exchange = channel.direct('work.to.do', durable: true)
channel.queue_bind('my_queue', 'work.to.do')

exchange.publish(msg)
