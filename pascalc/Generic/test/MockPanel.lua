require("PropertyContainer")
require("Logger")
require("MockComponent")
require("MockModulator")

MockPanel = {}
MockPanel.__index = MockPanel

local log = Logger("MockPanel")

setmetatable(MockPanel, {
  __index = PropertyContainer, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function MockPanel:_init()
  PropertyContainer._init(self)
  self.modulators = {}
  self.globalVariables = {}
end

function MockPanel:getBootstrapState()
  log:info("MockPanel getBootstrapState")
  return false
end

function MockPanel:setGlobalVariable()
  log:info("MockPanel setGlobalVariable")
end

function MockPanel:sendMidiMessageNow()
  log:info("MockPanel sendMidiMessageNow")
end

function MockPanel:getProgramState()
  log:info("MockPanel getProgramState")
  return false
end

function MockPanel:getGlobalVariable()
  log:info("MockPanel getGlobalVariable")
end

function MockPanel:getModulator(name)
  if self.modulators[name] == nil then
    self.modulators[name] = MockModulator(name)
  end
  return self.modulators[name]
end

function MockPanel:getComponent(name)
  log:info("MockPanel getComponent %s", name)
  return self:getModulator(name):getComponent()
end

function MockPanel:getModulatorWithProperty()
  log:info("MockPanel getModulatorWithProperty")
end

function MockPanel:getModulatorByName(name)
  log:info("MockPanel getModulatorByName %s", name)
  return self:getModulator(name)
end

function MockPanel:sendMidi()
  log:info("MockPanel sendMidi")
end
