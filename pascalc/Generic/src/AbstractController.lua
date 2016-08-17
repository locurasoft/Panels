__AbstractController = Object()

function __AbstractController:setMax(compName, max)
	panel:getComponent(compName):setProperty("uiSliderMax", max, false)
end

function __AbstractController:setText(compName, text)
	panel:getComponent(compName):setText(text)
end

function __AbstractController:setValue(modName, value)
	panel:getModulatorByName(modName):setValue(value, false)
end

function __AbstractController:getValue(modName)
	return panel:getModulatorByName(modName):getValue()
end

function __AbstractController:toggleVisibility(name, visible)
	if visible then
		panel:getComponent(name):setProperty("componentVisibility", 1, false)
	else
		panel:getComponent(name):setProperty("componentVisibility", 0, false)
	end
end

function __AbstractController:setListBoxContents(name, contents)
	panel:getComponent(name):setProperty("uiListBoxContent", contents, false)
end

function __AbstractController:setComboBoxContents(name, contents)
	panel:getComponent(name):setProperty("uiComboContent", contents, false)
end

function __AbstractController:toggleLayerVisibility(layerName, visible)
	local canvas = panel:getCanvas()
	if visible then
		canvas:getLayerByName(layerName):setPropertyInt("uiPanelCanvasLayerVisibility", 1)
	else
		canvas:getLayerByName(layerName):setPropertyInt("uiPanelCanvasLayerVisibility", 0)
	end
end

function __AbstractController:toggleActivation(name, enabled)
	if enabled then
		panel:getComponent(name):setProperty("componentDisabled", 0, false)
	else
		panel:getComponent(name):setProperty("componentDisabled", 1, false)
	end
end

function AbstractController()
	return __AbstractController:new()
end