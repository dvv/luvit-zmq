local Zmq = require './build/zmq'
_G.zmq = nil

local band = require('bit').band
local Utils = require('utils')
local Poller = require('core').Emitter:extend()

function Poller:add(sock, events, cb)
  local id = self.poller:add(sock, events)
  self.callbacks[id] = Utils.bind(cb, sock)
end

function Poller:remove(sock)
  local id = self.poller:remove(sock)
  self.callbacks[id] = nil
end

function Poller:insert(sock)
  local id = self.poller:add(sock, Zmq.POLLIN + Zmq.POLLOUT + Zmq.POLLERR)
end

function Poller:modify(sock, events, cb)
  local id
  if events ~= 0 and cb then
    id = self.poller:modify(sock, events)
    self.callbacks[id] = Utils.bind(cb, sock)
  else
    id = self:remove(sock)
  end
end

function Poller:poll(timeout)
  local poller = self.poller
  local count, err = poller:poll(timeout)
  if not count then return nil, err end
  local callbacks = self.callbacks
  for i = 1, count do
    local id, revents = poller:next_revents_idx()
    -- call backs
    callbacks[id](revents)
    -- fire events
    -- TODO: validate!
    --[[
    local sock = self.poller.items[id]
    p(sock)
    if band(revents, Zmq.POLLIN) then
      self:emit('data', sock, sock:recv(Zmq.DONTWAIT))
    end
    if band(revents, Zmq.POLLOUT) then
      self:emit('drain', sock)
    end
    if band(revents, Zmq.POLLERR) then
      self:emit('error', sock)
    end]]--
  end
  return count
end

function Poller:start()
  self.is_running = true
  while self.is_running do
    status, err = self:poll(-1)
    if not status then
      return false, err
    end
  end
  return true
end

function Poller:stop()
  self.is_running = false
end

function Poller:initialize(pre_alloc)
  self.poller = Zmq.ZMQ_Poller(pre_alloc)
  self.callbacks = {}
end

Zmq.Poller = Poller

return Zmq
