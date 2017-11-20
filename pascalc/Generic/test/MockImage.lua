require("LuaObject")
require("Logger")
require("lutils")

local log = Logger("MockImage")

MockImage = {}
MockImage.__index = MockImage

setmetatable(MockImage, {
  __index = LuaObject, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function MockImage:_init()
  LuaObject._init(self)
end
