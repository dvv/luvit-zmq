local Queue = require('./queue')

p = debug

p('REPL should block for 2 seconds, then unblock, then DONE1, DONE0')

-- smoke
Queue.queue(Queue.worker, function (...) p('DONE0', ...) end)
Queue.queue(Queue.worker2, function (...) p('DONE1', ...) end)

-- direct blocking call
p(Queue.worker2())

--[[
-- TODO: possible?
Queue.queue(function () Queue.worker2() end, function (...) p('DONE2', ...) end)
]]--
