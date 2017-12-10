require("PropertyContainer")
require("Logger")
require("MockComponent")
require("MockCanvas")
require("MockModulator")
local xml = require("xmlSimple").newParser()

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

function MockPanel:_init(panelPath, midiListener)
  PropertyContainer._init(self)
  self.modulators = {}
  self.midiListener = midiListener
  self.globalVariables = {}

  self.canvas = MockCanvas()

  local xmlParser = xml:loadFile(panelPath)
  local xmlElements = xmlParser.panel:children()
  for key, xmlElement in ipairs(xmlElements) do
    if xmlElement:name() == "modulator" then
      assert(self.modulators[xmlElement:name()] == nil, "Invalid panel. Found duplicate modulators.")
      local modulator = MockModulator(xmlElement["@name"])
      modulator:setVstIndex(tonumber(xmlElement["@vstIndex"]))
      if xmlElement["@modulatorMin"] ~= nil then
        modulator:getComponent():setProperty("uiSliderMin", xmlElement["@modulatorMin"])
      end
      if xmlElement["@modulatorMax"] ~= nil then
        modulator:getComponent():setProperty("uiSliderMax", xmlElement["@modulatorMax"])
      end
      if xmlElement["@modulatorCustomIndex"] ~= nil then
        modulator:setProperty("modulatorCustomIndex", xmlElement["@modulatorCustomIndex"])
      end
      if xmlElement["@modulatorCustomName"] ~= nil then
        modulator:setProperty("modulatorCustomName", xmlElement["@modulatorCustomName"])
      end
      if xmlElement["@modulatorCustomNameGroup"] ~= nil then
        modulator:setProperty("modulatorCustomNameGroup", xmlElement["@modulatorCustomNameGroup"])
      end

      if xmlElement["@luaModulatorValueChange"] ~= nil and xmlElement["@luaModulatorValueChange"] ~= "-- None" then
        modulator:setProperty("luaModulatorValueChange", xmlElement["@luaModulatorValueChange"])
      end
      if xmlElement.component["@componentGroupName"] ~= nil then
        modulator:getComponent():setProperty("componentGroupName", xmlElement.component["@componentGroupName"])
      end
      self.modulators[xmlElement["@name"]] = modulator
    end
  end
end

function MockPanel:setMidiListener(midiListener)
	self.midiListener = midiListener
end

function MockPanel:getBootstrapState()
  return false
end

function MockPanel:setGlobalVariable()
end

function MockPanel:sendMidiMessageNow(midiMessage)
  if self.midiListener ~= nil then
    self.midiListener(midiMessage:getData():toHexString(1))
  end
end

function MockPanel:getProgramState()
  return false
end

function MockPanel:getGlobalVariable()
end

function MockPanel:getModulator(name)
  return self.modulators[name]
end

function MockPanel:getComponent(name)
  return self:getModulator(name):getComponent()
end

function MockPanel:getModulatorByIndex(index)
  return self.modulators[index]
end

function MockPanel:getModulatorWithProperty(propName, propValue)
  for key, mod in pairs(self.modulators) do
    if mod:getProperty(propName) == propValue then
      return mod
    end
  end
  return nil
end

function MockPanel:getModulatorByName(name)
  return self:getModulator(name)
end

function MockPanel:sendMidi(buffer, millisecondCounterToStartAt)
end

function MockPanel:sendMidi(message, millisecondCounterToStartAt)
end

function MockPanel:sendMidi(m, millisecondCounterToStartAt)
end

function MockPanel:sendMidiNow(midiMessage)
  self:sendMidiMessageNow(midiMessage)
end

function MockPanel:getCanvas()
  return self.canvas
end

function MockPanel:getNumModulators()
  return table.getn(self.modulators)
end

function MockPanel:debugPrint()
  for key, mod in pairs(self.modulators) do
    mod:debugPrint()
  end
end
