require("LuaObject")

PropertyContainer = {}
PropertyContainer.__index = PropertyContainer

setmetatable(PropertyContainer, {
  __index = LuaObject, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function PropertyContainer:_init()
  LuaObject._init(self)
  self.properties = {}
end

function PropertyContainer:getPropertyDouble(name)
  return tonumber(self:getProperty(name))
end

function PropertyContainer:getPropertyString(name)
  return self:getProperty(name)
end

function PropertyContainer:getProperty(name)
  return self.properties[name]
end

function PropertyContainer:getPropertyInt(name)
  return tonumber(self:getProperty(name))
end

function PropertyContainer:setPropertyDouble(name, value)
  self.properties[name] = tostring(value)
end

function PropertyContainer:setProperty(name, value)
  self.properties[name] = value
end

function PropertyContainer:removeProperty(name)
  self.properties[name] = nil
end

function PropertyContainer:setPropertyColour(name, value)
  self.properties[name] = value
end

function PropertyContainer:setPropertyInt(name, value)
  self.properties[name] = tostring(value)
end
