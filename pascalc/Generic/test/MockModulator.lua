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
  self.name = name
  self.value = 0
  self.max = 0
  self.min = 0
  self.vstIndex = 0
  self.component = MockComponent(name)
end

function MockModulator:getComponent()
  log:info("MockModulator getComponent")
  return self.component
end

function MockModulator:getMinNonMapped()
  log:info("MockModulator getMinNonMapped")
  return self.min
end

function MockModulator:getMaxMapped()
  log:info("MockModulator getMaxMapped")
  return self.max
end

function MockModulator:setValueMapped(value)
  log:info("MockModulator setValueMapped")
  self.value = value
end

function MockModulator:getValueNonMapped()
  log:info("MockModulator getValueNonMapped")
  return self.value
end

function MockModulator:getValue()
  log:info("MockModulator getValue")
  return self.value
end

function MockModulator:getValueMapped()
  log:info("MockModulator getValueMapped")
  return self.value
end

function MockModulator:setValueNonMapped(value)
  log:info("MockModulator setValueNonMapped")
  self.value = value
end

function MockModulator:setValue(value)
  log:info("MockModulator setValue")
  self.value = value
end

function MockModulator:getMaxModulatorValue()
  log:info("MockModulator getMaxModulatorValue")
  return self.max
end

function MockModulator:getVstIndex()
  log:info("MockModulator getVstIndex")
  return self.vstIndex
end

function MockModulator:setModulatorValue()
  log:info("MockModulator setModulatorValue")
  return self.value
end

function MockModulator:getMinMapped()
  log:info("MockModulator getMinMapped")
  return self.min
end

function MockModulator:getLuaName()
  log:info("MockModulator getLuaName")
  return self.name
end

function MockModulator:getName()
  log:info("MockModulator getName")
  return self.name
end

function MockModulator:getMinModulatorValue()
  log:info("MockModulator getMinModulatorValue")
  return self.min
end

function MockModulator:getModulatorName()
  log:info("MockModulator getModulatorName")
  return self.name
end

function MockModulator:getMaxNonMapped()
  log:info("MockModulator getMaxNonMapped")
  return self.max
end

function MockModulator:getMidiMessage()
  log:info("MockModulator getMidiMessage")
end

function MockModulator:getModulatorValue()
  log:info("MockModulator getModulatorValue")
  return self.value
end
