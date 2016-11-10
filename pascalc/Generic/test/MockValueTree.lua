require("PropertyContainer")
require("Logger")

MockValueTree = {}
MockValueTree.__index = MockValueTree

local log = Logger("MockValueTree")

setmetatable(MockValueTree, {
  __index = LuaObject, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function MockValueTree:_init()
  LuaObject._init(self)
  self.properties = {}
end

function MockValueTree:setProperty(name, value, undo)
	self.properties[name] = value
end

function MockValueTree:getProperty(name)
  return self.properties[name]
end