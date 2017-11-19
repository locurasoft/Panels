require("LuaObject")
require("Logger")
require("lutils")

local log = Logger("Image")

Image = {}
Image.__index = Image

setmetatable(Image, {
  __index = LuaObject, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function Image:_init()
  LuaObject._init(self)
end
