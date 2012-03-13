local Queue = require('./queue')

p = debug

-- smoke
Queue.queue(0, function (...) p('DONE0', ...) end)
Queue.queue(1, function (...) p('DONE1', ...) end)

-- direct blocking call
p(Queue.worker2())
