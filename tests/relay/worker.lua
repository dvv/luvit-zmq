#!/usr/bin/env luvit

local ZMQ = require('../../')

-- context
local ctx = ZMQ.init(1)
p(ctx)

-- listening to relayed
local sub = ctx:socket(ZMQ.SUB)
sub:connect('tcp://127.0.0.1:65455')
sub:setopt(ZMQ.SUBSCRIBE, '')

-- publishing to relay
local pub = ctx:socket(ZMQ.PUB)
pub:connect('tcp://127.0.0.1:65454')

require('timer').setTimeout(400, function ()

--p(pub:send(('o'):rep(8192)))
pub:send(('o'):rep(1024))

-- loop
local n = 0
local time = require('os').time
local t0 = time()
while true do
  local msg = sub:recv()
  pub:send(msg)
  n = n + 1
  if n % 10000 == 0 then
    print(n, #msg, n / (time() - t0), 'msg/sec')
  end
end

end)
