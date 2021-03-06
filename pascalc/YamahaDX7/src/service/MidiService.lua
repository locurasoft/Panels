require("LuaObject")
require("Logger")
require("lutils")
require("mutils")

local log = Logger("MidiService")

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

