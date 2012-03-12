#!/usr/bin/env luvit

local ZMQ = require('zmq')

-- context
local ctx = ZMQ.init(1)

_G.r = assert(ctx:socket(ZMQ.PAIR))
assert(r:bind('inproc://test'))

_G.s = assert(ctx:socket(ZMQ.PAIR))
assert(s:connect('inproc://test'))

assert(s:send('hello'))
assert(r:recv() == 'hello')
