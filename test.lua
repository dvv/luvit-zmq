#!/usr/bin/env luvit

local Zmq = require('./')
assert(not _G.zmq)
assert(Zmq.init)
assert(Zmq.version())
p('Version:', Zmq.version())
