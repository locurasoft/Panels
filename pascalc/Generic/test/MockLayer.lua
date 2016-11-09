require("PropertyContainer")
require("Logger")

MockLayer = {}
MockLayer.__index = MockLayer

local log = Logger("MockLayer")

setmetatable(MockLayer, {
  __index = PropertyContainer, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function MockLayer:_init(name)
  PropertyContainer._init(self)
end
