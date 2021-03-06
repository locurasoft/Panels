require("LuaObject")
require("Logger")

AbstractController = {}
AbstractController.__index = AbstractController

local log = Logger("AbstractController")

setmetatable(AbstractController, {
  __index = LuaObject, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function AbstractController:_init()
  LuaObject._init(self)
end

function AbstractController:setMax(compName, max)
  panel:getComponent(compName):setProperty("uiSliderMax", max, false)
end

function AbstractController:setText(compName, text)
  panel:getComponent(compName):setText(text)
end

function AbstractController:getText(compName)
  local temp = panel:getComponent(compName):getProperty("uiLabelText")
  if temp == nil then
    return ""
  else
    return temp
  end
end

function AbstractController:setValueByCustomName(modName, value, mute)
  mute = mute or false
  local mod = panel:getModulatorWithProperty("modulatorCustomName", modName)
  if mod == nil then
    LOGGER:warn("Could not find modulator %s", modName)
  else
    mod:setValue(value, false, mute)
  end
end

function AbstractController:setValueByCustomNameMapped(modName, value, mute)
  mute = mute or false
  local mod = panel:getModulatorWithProperty("modulatorCustomName", modName)
  if mod == nil then
    LOGGER:warn("Could not find modulator %s", modName)
  else
    mod:setValueMapped(value, false, mute)
  end
end

function AbstractController:setValueByCustomIndex(index, value, mute)
  mute = mute or false
  local mod = self:getModulatorByCustomIndex(index)
  if mod == nil then
    LOGGER:warn("Could not find modulator %d", index)
  else
    mod:setValue(value, false, mute)
  end
end

function AbstractController:setValueByCustomIndexMapped(index, value, mute)
  mute = mute or false
  local mod = self:getModulatorByCustomIndex(index)
  if mod == nil then
    LOGGER:warn("Could not find modulator %d", index)
  else
    mod:setValueMapped(value, false, mute)
  end
end

function AbstractController:setValue(modName, value, mute)
  mute = mute or false
  local mod = panel:getModulatorByName(modName)
  if mod == nil then
    LOGGER:warn("Could not find modulator %s", modName)
  else
    mod:setValue(value, false, mute)
  end
end

function AbstractController:setValueForce(modName, value, mute)
  mute = mute or false
  local mod = panel:getModulatorByName(modName)
  if mod == nil then
    LOGGER:warn("Could not find modulator %s", modName)
  else
    mod:setValue(value, true, mute)
  end
end

function AbstractController:getValue(modName)
  return panel:getModulatorByName(modName):getValue()
end

function AbstractController:getValueByCustomName(modName)
  return panel:getModulatorWithProperty("modulatorCustomName", modName):getValue()
end

function AbstractController:getValueByCustomIndex(index)
  return self:getModulatorByCustomIndex(index):getValue()
end

function AbstractController:getModulatorByCustomName(modName)
  local mod = panel:getModulatorWithProperty("modulatorCustomName", modName)
  if mod ~= nil and mod:getProperty("modulatorCustomName") ~= nil then
    return mod
  else
    return nil
  end
end

function AbstractController:getModulatorByCustomIndex(index)
  local mod = panel:getModulatorWithProperty("modulatorCustomIndex", string.format("%d", index))
  if mod ~= nil and tonumber(mod:getProperty("modulatorCustomIndex")) == index then
    return mod
  else
    return nil
  end
end

function AbstractController:getModulatorName(mod)
  return mod:getProperty("name")
end

function AbstractController:toggleVisibility(name, visible)
  if visible then
    panel:getComponent(name):setProperty("componentVisibility", 1, false)
  else
    panel:getComponent(name):setProperty("componentVisibility", 0, false)
  end
end

function AbstractController:setListBoxContents(name, contents)
  panel:getComponent(name):setProperty("uiListBoxContent", contents, false)
end

function AbstractController:setComboBoxContents(name, contents)
  panel:getComponent(name):setProperty("uiComboContent", contents, false)
end

function AbstractController:toggleLayerVisibility(layerName, visible)
  local canvas = panel:getCanvas()
  if visible then
    canvas:getLayerByName(layerName):setPropertyInt("uiPanelCanvasLayerVisibility", 1)
  else
    canvas:getLayerByName(layerName):setPropertyInt("uiPanelCanvasLayerVisibility", 0)
  end
end

function AbstractController:toggleActivation(name, enabled)
  if enabled then
    panel:getComponent(name):setProperty("componentDisabled", 0, false)
  else
    panel:getComponent(name):setProperty("componentDisabled", 1, false)
  end
end

function AbstractController:setVisibleName(name, visibleName)
    panel:getComponent(name):setProperty("componentVisibleName", visibleName, false)
end

function AbstractController:setVisibleName(name, visibleName)
    panel:getComponent(name):setProperty("componentVisibleName", visibleName, false)
end

function AbstractController:setFixedSliderContent(name, content)
    panel:getComponent(name):setProperty("uiFixedSliderContent", content, false)
end

---
-- @function [parent=#AbstractController] sendMidiMessage
--
function AbstractController:sendMidiMessage(syxMsg)
  panel:sendMidiMessageNow(syxMsg:toMidiMessage())
end

---
-- @function [parent=#AbstractController] sendMidiMessages
--
function AbstractController:sendMidiMessages(msgs, interval)
  for k, nextMsg in pairs(msgs) do
    panel:sendMidi(nextMsg:toMidiMessage(), interval)
  end
end
