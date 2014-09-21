# RabbitMQ Presentation & Examples

# Work Queue Example

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
