# RabbitMQ Presentation & Examples

Code examples and documentation for a talk I'm giving
to [RubyFTW](http://rubyftw.org) on RabbitMQ.

# Work Queue Example

Code in the `work_queue` directory.

First, run `worker.rb`.  This script subscribes to a queue called
"my_queue", displays the messages it gets, and then sleeps a
random amount of time (to simulate doing some work).

You can publish a message directly to the queue by going to
your management console (http://localhost:15672/), navigating
to the queue, and using the web form to publish a message.

The script `direct_to_queue.rb` accomplishes the same thing
using Bunny.  This is just a demonstration - normally you want
to publish to an exchange and let the exchange deliver the message
to the right queue(s).  `to_exchange.rb` is the "right" way to
do it.

The script `a_bunch.rb` simulates generating a large load on the
exchange by publishing a number of messages (`ARGV[0]` is the number,
`ARGV[1]` is the message).  Note that `a_bunch.rb` should finish
pretty quickly, while the messages show up on the queue and stay
there until they are addressed by `worker.rb`.

We can scale up the number of `worker.rb` processes to work off
the queue more quickly.  Check out the queue in the admin panel
while the queue is being worked off.

Note that the number of unacknowledged messages at any time is
10.  That's because we set the channel prefetch option to 10
in `worker.rb`.  If any instance of `worker.rb` is killed,
the unacknowledge messages will be redelivered to the queue
automatically.

## Topics

Code in the `topics` directory.

We can declare a topic exchange from the command line using
rabbitmqadmin:

```bash
rabbitmqadmin declare exchange name=topic_example type=topic
```

Note that the exchange is declared as durable by default and that
once the exchange has been declared we can call the command multiple
times without causing problems.  That is, exchange declaration is
idempotent.  We can also declare the same exchange with bunny
as long as we match the parameter options:

```ruby
channel.topic('topic_excample', durable: true)
```

Bunny will return the existing exchange if we call the above,
which is useful for creating bindings:

```ruby
exchange = channel.topic('topic_example', durable: true)
queue = channel.queue('some_queue')
queue.bind(exchange, routing_key: '#')
```

When specifying routing keys, there are two wildcards: `#` and `*`.
`#` means match zero or more words, and `*` means match exactly
one word, where a "word" is defined as characters between periods.
So, for example a single `#` matches all routing keys.  A single
`*` matches `foo` but does not match `foo.bar`.  `foo.#` matches
`foo.bar` and `foo.bar.baz`, whereas `foo.*` matches `foo.bar`
but not `foo.bar.baz`.

The script `all.rb` launches a worker-like process that subscribes
to all messages on the `topic_example` exchange, regardless
of routing key.

Note that if we publish a message directly to a queue, the
routing key is irrelevant.  The routing key only matters
when a message passes through an exchange.

`routed.rb` shows an example of creating a queue and subscribing
to only specific routing keys.  Note we can create multiple
bindings to receive multiple keys.  In this case we subscribe
to routing keys `foo.logs.critical`, `foo.logs.warning`, and
`foo.error.*`.  A pattern like this could be used to send an
alert to the admin every time an error condition occurs.

You can use `publish_with_key.rb` to publish messages to the
`topic_example` with a routing key.  `ARGV[0]` is taken
as the routing key with the remainder of the command line
being the message.  Launch `all.rb` and `routed.rb` and
send some messages with various routing keys to see which one
shows up in which output.
