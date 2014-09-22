# encoding: utf-8

# publish a message to the 'topic_example' exchange
# with a specific routing key

require 'bunny'

connection = Bunny.new
connection.start
channel = connection.create_channel

routing_key = ARGV.shift
msg = ARGV.join(' ')

exchange = channel.topic('topic_example', durable: true)
exchange.publish(msg, routing_key: routing_key)
