#!/usr/bin/env luvit

local Zmq = require('../../')

-- create context
local ctx = Zmq.init(1)

-- listening to messages
debug('Push to *:65454')
local sub = ctx:socket(Zmq.SUB)
sub:bind('tcp://*:65454')
sub:setopt(Zmq.SUBSCRIBE, '')

-- publishing to subscribers
debug('Subscribe to *:65455')
local pub = ctx:socket(Zmq.PUB)
pub:bind('tcp://*:65455')

-- loop
local msg = Zmq.zmq_msg_t()
while (1) do
  -- receive message
  -- break if interrupted
  if not sub:recv_msg(msg) then break end
  -- broadcast message
  pub:send_msg(msg)
end

-- cleanup
pub:close()
sub:close()
ctx:term()
