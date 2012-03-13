#!/usr/bin/env luvit

local ZMQ = require('../')

-- context
local ctx = ZMQ.init(1)

local r = assert(ctx:socket(ZMQ.PAIR))
local s = assert(ctx:socket(ZMQ.PAIR))

local count = 0

local polls = {}
local poller = ZMQ.ZMQ_Poller.new(2)
polls[poller:add(r, ZMQ.POLLIN + ZMQ.POLLERR)] = function (revents)
  --p('R', revents)
  assert(r:recv() == 'hello')
  count = count + 1
  if count == 100000 then process.exit() end
end
polls[poller:add(s, ZMQ.POLLOUT + ZMQ.POLLERR)] = function (revents)
  --p('S', revents)
  assert(s:send('hello'))
end
polls[poller:add(0, ZMQ.POLLIN + ZMQ.POLLERR)] = function (revents)
  p('STDIN', revents)
  process.exit(0)
end

assert(r:bind('inproc://test'))
assert(s:connect('inproc://test'))

while true do
  poller:poll(-1)
  while true do
    local idx, revents = poller:next_revents_idx()
    if idx < 0 then break end
    if polls[idx] then
      polls[idx](revents)
    end
  end
end
