# encoding: utf-8

# This is an example of using Bunny to publish directly to
# a queue.  Normally you want to publish to an exchange -
# see "to_exchange.rb".

require 'bunny'

connection = Bunny.new
connection.start
channel = connection.create_channel

msg = ARGV[0] || 'Hi! What\'s up?'

queue = channel.queue('my_queue')
queue.publish(msg)
