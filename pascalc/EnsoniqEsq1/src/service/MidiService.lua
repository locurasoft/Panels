require("LuaObject")
require("Logger")
require("lutils")
require("mutils")

local log = Logger("MidiService")

local CHECKSUM_START = 5

MidiService = {}
MidiService.__index = MidiService

setmetatable(MidiService, {
  __index = LuaObject, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

---
--@module __MidiService
function MidiService:_init()
  LuaObject._init(self)
end

function MidiService:v2n(value, data, offset)
  local tmp = mutils.d2n(value)
  data:copyFrom(tmp, offset, 2)
--    self.data:setByte(offset, value % 16)
--    self.data:setByte(offset + 1, math.floor(value / 16))
end

function MidiService:n2v(data, offset)
  return mutils.n2d(data:getByte(offset), data:getByte(offset + 1))
--  return data:getByte(offset) + data:getByte(offset + 1) * 16
end