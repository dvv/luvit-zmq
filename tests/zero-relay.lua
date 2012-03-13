#!/usr/bin/env luvit

local Table = require('table')
local ZMQ = require('zmq')

-- create context
local ctx = ZMQ.init(1)

--
-- relay server
--

-- listen to messages
local ssub = ctx:socket(ZMQ.SUB)
ssub:bind('tcp://*:65454')
ssub:setopt(ZMQ.SUBSCRIBE, '')
debug('Push to *:65454')

-- publish to subscribers
local spub = ctx:socket(ZMQ.PUB)
spub:bind('tcp://*:65455')
debug('Subscribe to *:65455')

--
-- relay client
--

-- listening to relayed
local csub = ctx:socket(ZMQ.SUB)
csub:connect('tcp://127.0.0.1:65455')
csub:setopt(ZMQ.SUBSCRIBE, '')
debug('Connected to *:65455')

-- publishing to relay
local cpub = ctx:socket(ZMQ.PUB)
cpub:connect('tcp://127.0.0.1:65454')
debug('Connected to *:65454')

ZMQ.sleep(1)

local before = '<<<'
local ping = ('o'):rep(8)--1024)
local after = '>>>'
local str = before .. ping .. after
cpub:send(before, ZMQ.SNDMORE)
cpub:send(ping, ZMQ.SNDMORE)
cpub:send(after)
debug('Sent ping')

local function aaa(...)
  print(...)
  return true
end

-- server loop
do
  local n = 0
  local msg = ZMQ.zmq_msg_t()
  while ssub:recv_msg(msg, 1) and aaa('RECVED?')
    and spub:send_msg(msg, ssub:getopt(ZMQ.RCVMORE) == 1 and ZMQ.SNDMORE)
  do
    print('RECV')
    --[[
    n = n + 1
    if n % 10000 == 0 then print('RELAYED', n) end
    ]]--
  end
end

-- client loop
do
  local n = 0
  local time = require('os').time
  local t0 = time()

  local function relay(msg)
    cpub:send(msg)
    n = n + 1
    if n % 10000 == 0 then
      print(n, #msg, n / (time() - t0), 'msg/sec')
    end
    if n == 100000 then
      process.exit()
    end
  end

  while true do
    debug('CRECV')
    local msg = { csub:recv(1) }
    while csub:getopt(ZMQ.RCVMORE) == 1 do
      msg[#msg + 1] = csub:recv(1)
    end
    msg = Table.concat(msg)
    assert(msg == str)
    relay(msg)
  end
end
