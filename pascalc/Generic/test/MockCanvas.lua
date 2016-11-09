require("PropertyContainer")
require("MockLayer")
require("Logger")

MockCanvas = {}
MockCanvas.__index = MockCanvas

local log = Logger("MockCanvas")

setmetatable(MockCanvas, {
  __index = PropertyContainer, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function MockCanvas:_init(name)
  PropertyContainer._init(self)
  self.layers = {}
end

function MockCanvas:getLayerByName(layerName)
  if self.layers[layerName] == nil then
    self.layers[layerName] = MockLayer(layerName)
  end
	return self.layers[layerName]
end
