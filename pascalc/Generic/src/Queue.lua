require("LuaObject")
require("Logger")

local log = Logger("Queue")

Queue = {}
Queue.__index = Queue

setmetatable(Queue, {
  __index = LuaObject, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

---
--@module __Queue
function Queue:_init()
  LuaObject._init(self)
  self.first = 0
  self.last = -1
  self.list = {}
end

function Queue:pushFirst(value)
  local first = self.first - 1
  self.first = first
  self.list[first] = value
end

function Queue:pushLast(value)
  local last = self.last + 1
  self.last = last
  self.list[last] = value
end

function Queue:popFirst()
  local first = self.first
  if first > self.last then return nil end
  local value = self.list[first]
  self.list[first] = nil        -- to allow garbage collection
  self.first = first + 1
  return value
end

function Queue:popLast()
  local last = self.last
  if self.first > last then return nil end
  local value = self.list[last]
  self.list[last] = nil         -- to allow garbage collection
  self.last = last - 1
  return value
end

function Queue:getSize()
	if self.last <= 0 then
	 return 0
else
  return self.last - self.first + 1
end
end