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

function AbstractController:setValue(modName, value)
	panel:getModulatorByName(modName):setValue(value, false)
end

function AbstractController:getValue(modName)
	return panel:getModulatorByName(modName):getValue()
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
