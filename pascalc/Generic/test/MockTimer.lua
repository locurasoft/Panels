require("LuaObject")
require("Logger")
require("lutils")

MockTimer = {}
MockTimer.__index = MockTimer

setmetatable(MockTimer, {
  __index = LuaObject, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function MockTimer:_init()
  LuaObject._init(self)
end

function MockTimer:stopTimer()
	
end

function MockTimer:startTimer()
  
end

function MockTimer:setCallback()
  
end
