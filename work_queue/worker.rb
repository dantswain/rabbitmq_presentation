# encoding: utf-8

require 'bunny'

connection = Bunny.new

# normally in an application we would not
# swallow this error but instead let it bubble
# up and have the caller decide how to handle it
begin
  connection.start
rescue Bunny::TCPConnectionFailed
  STDERR.puts 'Could not connect to RabbitMQ'
  exit(1)
end

channel = connection.create_channel

# setting prefetch limits the number of messages
# that the broker will send to the consumer at
# one time without acknowledgement
#
# setting this number high reduces network latency
# but one worker can "hog" all of the messages
#
# setting this number low increases network latency
# but ensures "fair" distribution of messages
channel.prefetch(10)

queue_name = 'my_queue'
queue_opts = {
  durable: false,      # default
  auto_delete: false,  # default
  exclusive: false,    # default
  arguments: {}        # possibly used by RabbitMQ extensions
}

queue = channel.queue(queue_name, queue_opts)

# by specifying manual_ack: true here, we ensure
# that the worker does not acknowledge the message
# until it is actually done working with the message
#
# it also gives the client a chance to reject
# or nack (negative ack) the message
puts 'waiting for a message...'
queue.subscribe(block: true, manual_ack: true) do
  |delivery_info, msg_props, body|
  puts 'GOT message'
  puts "\tdelivery_info = #{delivery_info.inspect}"
  puts "\tmsg_props = #{msg_props.inspect}"
  puts "\tbody = #{body}"

  # simulate a delay due to some work being done
  sleep(rand)

  # acknowledge the message
  channel.ack(delivery_info.delivery_tag)
end
