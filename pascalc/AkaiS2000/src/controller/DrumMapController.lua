local log = Logger("DrumMapController")

local markGroup = function(groupName, error)
	local color = "FF7A7269"
	if error then
		color = "FFEA402A"
		retval = false
	end
	
	panel:getComponent(groupName):setProperty("uiGroupOutlineColour1", color, false)
end

local disablePad = function(comp)
	comp:setProperty("uiButtonColourOff", "ff93b4ff", false)
	comp:setProperty("uiButtonColourOn", "ff93b4ff", false)
end

local enablePad = function(comp)
	comp:setProperty("uiButtonColourOff", "0xff0000ff", false)
	comp:setProperty("uiButtonColourOn", "0xff0000ff", false)
end

local setPadValue = function(padName, value)
	local pad = panel:getComponent(padName)

	if value == nil or value == "" then
		pad:setProperty("componentVisibleName", "", true)	
		pad:setProperty("componentLabelVisible", 0, true)
	else
		pad:setProperty("componentLabelVisible", 1, true)
		pad:setProperty("componentVisibleName", value, true)
	end
end

__DrumMapController = AbstractController()

function __DrumMapController:setDrumMap(drumMap)	
	local drumMapListener = function(dm)
		self:updateDrumMap(dm)
	end
	drumMap:addListener(drumMapListener)
end

function __DrumMapController:updateDrumMap(drumMap)	
	--
	-- Update pads
	--
	panel:getComponent("drumMapSelectionLabel"):setProperty("uiLabelText", "", false)

	local numPads = drumMap:getNumKeyGroups()

	for i = 1,16 do
		local padName = string.format("drumMap-%d", i)
		--log:fine("padName %s", padName)
		if drumMap:isSelectedKeyGroup(i) then
			--log:fine("selected")
			local comp = panel:getComponent(padName)
			local kgName = self:getKeyGroupName(comp)

			enablePad(comp)			
			panel:getComponent("drumMapSelectionLabel"):setProperty("uiLabelText", kgName, false)
		else
			--console("not selected")
			disablePad(panel:getComponent(padName))
		end
		local samplesOfPad = drumMap:getSamplesOfKeyGroup(i)
		setPadValue(padName, samplesOfPad)

		self:toggleVisibility(padName, i <= numPads)
	end

	--
	-- Update floppy info
	--
	local numFloppies = drumMap:getNumFloppies()
	local numFloppiesText = string.format("# Floppies to be transfered: %d", numFloppies)
	panel:getComponent("numFloppiesLabel"):setText(numFloppiesText)

	local floppyUsagePercent = drumMapSrvc:getFloppyUsagePercent(drumMap)
	local floppyUsageBar = panel:getModulatorByName("floppyUsageBar")
	floppyUsageBar:setValue(floppyUsagePercent, false)
	
	local color = "FF99CE65"
	if floppyUsagePercent > 90 then
		color = "FFCC3824"
	elseif floppyUsagePercent > 75 then
		color = "FFCCAA24"
	end
	floppyUsageBar:getComponent():setProperty("uiSliderThumbColour", color, false)

	--
	-- Update assignment controls
	--
	self:toggleActivation("assignSample", drumMap:isReadyForAssignment())
	self:toggleActivation("clearSamples", not drumMap:isClear())
	self:toggleActivation("transferSamples", not drumMap:isClear())

	--
	-- Update range controls
	--
	local isPadSelected = drumMap:getSelectedKeyGroup() ~= nil
	self:toggleActivation("drumMapLowKey", isPadSelected)
	self:toggleActivation("drumMapHighKey", isPadSelected)
	self:toggleActivation("defaultDrumMapButton", isPadSelected)

	if isPadSelected then
		local keyRanges = drumMap:getKeyRangeValues()
		-- console(string.format("keyRagnes: %d, %d", keyRanges[1], keyRanges[2]))
		panel:getModulatorByName("drumMapLowKey"):setValue(keyRanges[1], false)
		panel:getModulatorByName("drumMapHighKey"):setValue(keyRanges[2], false)
	end
end

function __DrumMapController:updateStatus(message)
	panel:getComponent("lcdLabel"):setText(message)
end

function __DrumMapController:getKeyGroupName(comp)
	local grpName = comp:getProperty("componentGroupName")
	local kgIndex = string.sub(grpName, 9, string.find(grpName, "-grp") - 1)
	--log:fine("Found %s", kgIndex)
	return string.format("KeyGroup %s", kgIndex)
end

function __DrumMapController:verifyTransferSettings()
	local retval = true
	
	markGroup("s2kDiePathGroup", not s2kDieSrvc:getS2kDiePath():exists())
	markGroup("workPathGroup", not workFolder:exists())

	-- Reset all values
	markGroup("hxcPathGroup", false)
	markGroup("setfdprmPathGroup", false)
	markGroup("transferMethodGroup", false)

	local loadMethod = panel:getModulatorByName("transferMethod"):getValue()
	log:fine("[verifyTransferSettings] %d", loadMethod)

	if loadMethod == 0 then
		-- Floppy
		markGroup("setfdprmPathGroup", not setfdprmPath:exists())
	elseif loadMethod == 1 then
		-- HxC
		markGroup("hxcPathGroup", not File(hxcSrvc:getHxcPath()):exists())
	else
		-- MIDI -> unsupported
		markGroup("transferMethodGroup", true)
	end
	return retval
end

function DrumMapController()
	return __DrumMapController:new()
end
