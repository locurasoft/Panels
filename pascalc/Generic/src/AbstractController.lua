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

function AbstractController:setValueByCustomName(modName, value)
  local mod = panel:getModulatorWithProperty("modulatorCustomName", modName)
  if mod == nil then
    LOGGER:warn("Could not find modulator %s", modName)
  else
    mod:setValue(value, false)
  end
end

function AbstractController:setValueByCustomNameMapped(modName, value)
  local mod = panel:getModulatorWithProperty("modulatorCustomName", modName)
  if mod == nil then
    LOGGER:warn("Could not find modulator %s", modName)
  else
    mod:setValueMapped(value, false)
  end
end

function AbstractController:setValue(modName, value)
  local mod = panel:getModulatorByName(modName)
  if mod == nil then
    LOGGER:warn("Could not find modulator %s", modName)
  else
    mod:setValue(value, false)
  end
end

function AbstractController:setValueForce(modName, value)
  local mod = panel:getModulatorByName(modName)
  if mod == nil then
    LOGGER:warn("Could not find modulator %s", modName)
  else
    mod:setValue(value, true)
  end
end

function AbstractController:getValue(modName)
  return panel:getModulatorByName(modName):getValue()
end

function AbstractController:getValueByCustomName(modName)
  return panel:getModulatorWithProperty("modulatorCustomName", modName):getValue()
end

function AbstractController:getModulatorByCustomName(modName)
  return panel:getModulatorWithProperty("modulatorCustomName", modName)
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
