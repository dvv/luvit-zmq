#!/usr/bin/env luvit

local Worker = require('worker').Worker

local ZMQ = require('../')

-- context
local ctx = ZMQ.init(1)

local r = assert(ctx:socket(ZMQ.PAIR))
local s = assert(ctx:socket(ZMQ.PAIR))

local count = 0

local poller = ZMQ.Poller:new(2)
poller:add(r, ZMQ.POLLIN, function(sock, revents)
  --p('R')
  while r:recv(ZMQ.NOBLOCK) == 'hello' do
    count = count + 1
    if count == 100000 then
      p('100000 messages passed')
      poller:stop()
      process.exit()
    end
  end
  --p('B', count)
end)
poller:add(s, ZMQ.POLLOUT, function(sock, revents)
  --p('S')
  assert(s:send('hello'))
end)

assert(r:bind('inproc://test'))
assert(s:connect('inproc://test'))

p(type(poller.poller.poll))
--poller:start()
--Worker:new(poller.start, poller)
Worker:new():on('end', function (...)
  p('END', ...)
end):on('error', function (err)
  p('ERROR', err)
end):run(poller.poller.poll, poller.poller, -1)
