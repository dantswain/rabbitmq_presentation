# encoding: utf-8

# example of subscribing to specific routing keys
# on a topic exchange

require 'bunny'

connection = Bunny.new

begin
  connection.start
rescue Bunny::TCPConnectionFailed
  STDERR.puts 'Could not connect to RabbitMQ'
  exit(1)
end

channel = connection.create_channel

channel.prefetch(10)

# ensure that the exchange exists
exchange = channel.topic('topic_example', durable: true)

queue_name = 'topic_alerts'
queue_opts = {
  durable: false,      # default
  auto_delete: false,  # default
  exclusive: false,    # default
  arguments: {}        # possibly used by RabbitMQ extensions
}

queue = channel.queue(queue_name, queue_opts)

queue.bind(exchange, routing_key: 'foo.logs.critical')
queue.bind(exchange, routing_key: 'foo.logs.warning')
queue.bind(exchange, routing_key: 'foo.error.*')

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
