#!/usr/bin/env luvit

local ZMQ = require('../')

-- context
local ctx = ZMQ.init(1)

local r = assert(ctx:socket(ZMQ.PAIR))
assert(r:bind('inproc://test'))

local s = assert(ctx:socket(ZMQ.PAIR))
assert(s:connect('inproc://test'))

assert(s:send('hello'))
assert(r:recv() == 'hello')
