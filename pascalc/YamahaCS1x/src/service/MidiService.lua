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
  data:copyFrom(mutils.d2n(value), offset, 2)
end

function MidiService:n2v(data, offset)
  return mutils.n2d(data:getByte(offset), data:getByte(offset + 1))
end