#!/usr/bin/env luvit

local ZMQ = require('zmq')

-- context
local ctx = ZMQ.init(1)

local r = assert(ctx:socket(ZMQ.PAIR))
local s = assert(ctx:socket(ZMQ.PAIR))

local count = 0

local poller = ZMQ.ZMQ_Poller.new(2)
poller:add(r, ZMQ.POLLIN, function(sock, revents)
  p('R', sock, revents)
  while assert(s:recv(ZMQ.NOBLOCK)) do
    count = count + 1
    if count == 100000 then
      poller:stop()
      process.exit()
    end
  end
end)
poller:add(s, ZMQ.POLLOUT, function(sock, revents)
  p('S', sock, revents)
  while assert(s:send('hello')) do
    --[[count = count + 1
    if count == 100000 then
      poller:stop()
      process.exit()
    end]]--
  end
end)

assert(r:bind('inproc://test'))
assert(s:connect('inproc://test'))

poller:start()
