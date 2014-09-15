# encoding: utf-8

require 'bunny'

connection = Bunny.new
connection.start
channel = connection.create_channel

msg = ARGV[0] || 'Hi! What\'s up?'

queue = channel.queue('my_queue')
queue.publish(msg)
