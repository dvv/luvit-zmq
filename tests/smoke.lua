#!/usr/bin/env luvit

local Zmq = require('../')
assert(not _G.zmq)
assert(Zmq.init and Zmq.init(1))
assert(Zmq.version())
p(Zmq.version())
