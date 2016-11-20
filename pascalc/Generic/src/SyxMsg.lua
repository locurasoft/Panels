require("LuaObject")

SyxMsg = {}
SyxMsg.__index = SyxMsg

setmetatable(SyxMsg, {
  __index = LuaObject, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function SyxMsg:_init()
  LuaObject._init(self)
  self.data = nil
end

function SyxMsg:toMidiMessage()
	return CtrlrMidiMessage(self.data)
end

function SyxMsg:toString()
	return self.data:toHexString(1)
end
