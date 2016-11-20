require("LuaObject")
require("Logger")

MockMidiMessage = {}
MockMidiMessage.__index = MockMidiMessage

local log = Logger("MockMidiMessage")

setmetatable(MockMidiMessage, {
  __index = LuaObject, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function MockMidiMessage:_init(data)
  LuaObject._init(self)
  self.data = data
end

function MockMidiMessage:getData()
  return self.data
end
