require("PropertyContainer")
require("Logger")

MockModulator = {}
MockModulator.__index = MockModulator

local log = Logger("MockModulator")

setmetatable(MockModulator, {
  __index = PropertyContainer, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function MockModulator:_init(name)
  PropertyContainer._init(self)
  self:setProperty("name", name)
  self.value = 0
  self.valueMapped = 0
  self.vstIndex = 0
  self.component = MockComponent(name, self)
end

function MockModulator:getComponent()
  return self.component
end

function MockModulator:getMinNonMapped()
  return self:getMinModulatorValue()
end

function MockModulator:getMaxMapped()
  return self:getMaxModulatorValue()
end

function MockModulator:setValueMapped(value)
  self.valueMapped = value
end

function MockModulator:getValueNonMapped()
  return self.value
end

function MockModulator:getValue()
  return self.value
end

function MockModulator:getValueMapped()
  return self.valueMapped
end

function MockModulator:getMaxModulatorValue()
  return self.component:getPropertyInt("uiSliderMax")
end

function MockModulator:getVstIndex()
  return self.vstIndex
end

function MockModulator:setVstIndex(vstIndex)
  self.vstIndex = vstIndex
end

function MockModulator:getMinMapped()
  return self:getMinModulatorValue()
end

function MockModulator:getLuaName()
  return self.name
end

function MockModulator:getName()
  return self:getProperty("name")
end

function MockModulator:getMinModulatorValue()
  return self.component:getPropertyInt("uiSliderMin")
end

function MockModulator:getModulatorName()
  return self.name
end

function MockModulator:getMaxNonMapped()
  return self:getMaxModulatorValue()
end

function MockModulator:getMidiMessage()
end

function MockModulator:getModulatorValue()
  return self.value
end

function MockModulator:setValueNonMapped(value)
  self.value = value
end

function MockModulator:setValue(value)
  self.value = value
  local valChangeFunc = self:getProperty("luaModulatorValueChange")
  if valChangeFunc ~= nil and valChangeFunc ~= "" then
    _G[valChangeFunc](self, value)
  end
end

function MockModulator:setModulatorValue(value)
  self:setValue(value)
end

function MockModulator:debugPrint()
  if self:getProperty("name") == nil then
    log:info("noname")
  elseif self.value == nil then
    log:info("%s;nil", self:getProperty("name"))
  else
    log:info("%s;%d", self:getProperty("name"), self.value)
  end
end
