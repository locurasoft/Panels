local log = Logger("DrumMap")

__DrumMap = Dispatcher()

function __DrumMap:setSelectedSample(selectedSample)
	self.selectedSample = selectedSample
	self:notifyListeners()
end

function __DrumMap:setSelectedKeyGroup(selectedKg)
	if type(selectedKg) == "string" then
		selectedKg = tonumber(string.sub(selectedKg, string.find(selectedKg, "-") + 1, #selectedKg))
	end

	if self.selectedKg == selectedKg then
		self.selectedKg = nil
	else
		self.selectedKg = selectedKg
	end
	self:notifyListeners()
end

function __DrumMap:isSelectedKeyGroup(padName)
	return padName == self.selectedKg
end

function __DrumMap:getSelectedSample()
	return self.selectedSample
end

function __DrumMap:getSelectedKeyGroup()
	return self.selectedKg
end

function __DrumMap:getNumFloppies()
	return table.getn(self.floppyList)
end

function __DrumMap:isReadyForAssignment()
	return self.selectedSample ~= nil and self.selectedKg ~= nil
end

function __DrumMap:getCurrentFloppyUsage()
	return self.currentFloppyUsage
end

function __DrumMap:setCurrentFloppyUsage(currentFloppyUsage)
	self.currentFloppyUsage = currentFloppyUsage
	self:notifyListeners()
end

function __DrumMap:addNewFloppy()
	log:info("add new floppy: %d", self:getNumFloppies())
	local floppy = {}
	table.insert(self.floppyList, floppy)
	self.currentFloppyUsage = 0
	return floppy
end

function __DrumMap:insertToCurrentFloppy(sample)
	local floppy = self:getFloppy(self:getNumFloppies())
	table.insert(floppy, sample)
end

function __DrumMap:getFloppy(index)
	return self.floppyList[index]
end

function __DrumMap:retrieveNextFloppy()
	return table.remove(self.floppyList)
end

function __DrumMap:setNumKeyGroups(numKeyGroups)
	local currKeyGroups = table.getn(self.keyGroups)
	while currKeyGroups < numKeyGroups do
		local kg = KeyGroup()
		kg:setLowNote(currKeyGroups)
		kg:setHighNote(currKeyGroups)

		table.insert(self.keyGroups, kg)
		currKeyGroups = table.getn(self.keyGroups)
	end

	while table.getn(self.keyGroups) > numKeyGroups do
		table.remove(self.keyGroups)
	end
	self:notifyListeners()
end

function __DrumMap:addSampleToSelectedKeyGroup(sample)
	log:fine("Selected kg %d", self.selectedKg)
	local selectedKeyGroup = self.keyGroups[self.selectedKg]
	assert(selectedKeyGroup:numZones() < 4, "A key group can only contain 4 zones")
	selectedKeyGroup:addSampleZone(sample)
	self:notifyListeners()
end	

function __DrumMap:addFileToSelectedKeyGroup(file)
	log:fine("Selected kg %d", self.selectedKg)
	local selectedKeyGroup = self.keyGroups[self.selectedKg]
	assert(selectedKeyGroup:numZones() < 4, "A key group can only contain 4 zones")
	selectedKeyGroup:addFileZone(file)
	self:notifyListeners()
end

function __DrumMap:getNumSamplesOnSelectedKeyGroup()
	local selectedKeyGroup = self.keyGroups[self.selectedKg]
	if selectedKeyGroup == nil then
		return 0
	else
		return selectedKeyGroup:numZones()
	end
end

function __DrumMap:getSamplesOfKeyGroup(kgIndex)
	local keyGroup = self.keyGroups[kgIndex]
	if keyGroup == nil then
		return nil
	end
	local samplesOfKg = ""
	local first = true
	for k,zone in pairs(keyGroup:getZones()) do
		local sampleName = zone:getSampleName()
		if string.len(sampleName) > 20 then
			sampleName = string.format("%s..", string.sub(sampleName, 0, 19))
		end

		if first then
			first = false
			samplesOfKg = sampleName
		else
			samplesOfKg = string.format("%s\n%s", samplesOfKg, sampleName)
		end
	end
	return samplesOfKg
end

function __DrumMap:isClear()
	for k,keyGroup in pairs(self.keyGroups) do
		return false
	end
	return true
end

function __DrumMap:clear()
	self.currentFloppyUsage = 0
	self.keyGroups = {}
	self.floppyList = {}
	self:notifyListeners()
end

function __DrumMap:resetSelectedKeyRange()
	if self.selectedKg == nil then
		console("DrumMap:resetSelectedKeyRange - No pad selected")
		return
	end
	local defaultValue = self.selectedKg - 1
	self.keyRanges[self.selectedKg] = { defaultValue, defaultValue }
	self:notifyListeners()
end

function __DrumMap:setKeyRange(endIndex, value)
	local index = tonumber(endIndex)
	if index < 1 or index > 2 then
		console(string.format("Weird endIndex %d", index))
		return
	end
	local rangeValues = self.keyRanges[self.selectedKg]
	rangeValues[index] = value
	self:notifyListeners()
end

function __DrumMap:getKeyRangeValues()
	if self.selectedKg == nil then
		return { 0, 0 }
	else
		return self.keyRanges[self.selectedKg]
	end
end

function __DrumMap:replaceKeyGroupZoneWithSample(keyGroupName, zoneIndex, stereoSample)
	local keyGroup = self.keyGroups[keyGroupName]
	if type(stereoSample) == "string" then
		-- Mono sample
		keyGroup:replaceWithMonoSample(zoneIndex, stereoSample)
	else
		-- Stereo sample
		keyGroup:replaceZoneWithStereoSample(zoneIndex, stereoSample[1], stereoSample[2])
	end
	self:notifyListeners()
end

function __DrumMap:resetAllRanges()
	setRangesToDefault(self.keyRanges)
	self:notifyListeners()
end

function __DrumMap:hasLoadedAllSamples()
	for k,keyGroup in pairs(self.keyGroups) do
		local zones = keyGroup:getZones()
		for k2, zone in pairs(zones) do
			if not zone:isSampleLoaded() then
				return false
			end
		end
	end
	return true
end

function __DrumMap:getKeyGroups()
	return self.keyGroups
end

function __DrumMap:getNumKeyGroups()
	return table.getn(self.keyGroups)
end

-- Used for floppy image selection
function __DrumMap:getLaunchButtonState()
	if floppyImgPath == nil then
		if self.selectedKg ~= nil and self.selectedSample ~= nil then
			return ""
		else
			return "Select a sample and a key group"
		end
	else
		if self.selectedKg ~= nil or self.setSelectedSample ~= nil then
			return "You cannot load both an image and samples.\nPlease clear some data"
		else
			return ""
		end
	end
end

function DrumMap(data)
	local kRngs = {}
	for i = 0,15 do
		table.insert(kRngs, {i, i})
	end

	return __DrumMap:new {
		keyGroups = {},
		floppyList = {},
		selectedSample = nil,
		selectedKg = nil,
		currentFloppyUsage = 0,
		numKgs = 16,
		keyRanges = kRngs,
		[LUA_CLASS_NAME] = "DrumMap"
	}
end
