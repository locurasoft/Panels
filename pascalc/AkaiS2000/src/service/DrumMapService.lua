local log = Logger("DrumMapService")
local MAX_FLOPPY_SIZE = 1400000
local MAX_SAMPLE_NAME_SIZE = 10

__DrumMapService = Object()

local getFileSize = function(file)
	local wavFile = io.open(file:getFullPathName(), "r")
	local size = wavFile:seek("end")    -- get file size
	wavFile:close()
	return size
end

function __DrumMapService:setDrumMap(drumMap)
	self.drumMap = drumMap
end

function __DrumMapService:setSampleList(sampleList)
	self.sampleList = sampleList
	local sampleListListener = function(sl)
		self:updateDrumMap(sl)
	end
	sampleList:addListener(sampleListListener)
end

function __DrumMapService:getSamplerFileName(filename)	
	local sampleName = string.upper (filename)
	if #sampleName > MAX_SAMPLE_NAME_SIZE then
		sampleName = string.sub(sampleName, 1, MAX_SAMPLE_NAME_SIZE)
	elseif #sampleName < MAX_SAMPLE_NAME_SIZE then
		sampleName = sampleName .. string.rep(" ", MAX_SAMPLE_NAME_SIZE - #sampleName)
	end
	return sampleName
end

function __DrumMapService:findStereoCounterpart(sampleList, stereoPartnerName, arrayOffset)
	--log:fine("findStereoCounterpart %s", stereoPartnerName))
	for k,v in pairs(sampleList) do
		if type(v) ~= "string" and v[arrayOffset] == stereoPartnerName then
			return k
		end
	end
	return -1
end

function __DrumMapService:generateStereoSampleList(sampleList)
	local retVal = {}
	local leftIndex = 1
	local rightIndex = 2

	for name,v in pairs(sampleList) do
		local suffix = string.sub(name, #name - 1, #name)
		if suffix == "-L" then
			-- Search for -R counterpart
			local matchingIndex = self:findStereoCounterpart(retVal, string.format("%s%s", string.sub(name, 1, #name - 1), "R"), rightIndex)
			if matchingIndex > 0 then
				retVal[matchingIndex][leftIndex] = name
			else
				local temp = {}
				temp[leftIndex] = name
				table.insert(retVal, temp)
			end
		elseif suffix == "-R" then
			-- Search for -L counterpart
			local matchingIndex = self:findStereoCounterpart(retVal, string.format("%s%s", string.sub(name, 1, #name - 1), "L"), leftIndex)
			if matchingIndex > 0 then
				retVal[matchingIndex][rightIndex] = name
			else
				local temp = {}
				temp[rightIndex] = name
				table.insert(retVal, temp)
			end
		else
			-- Mono sample
			table.insert(retVal, name)
		end
	end
	return retVal
end

function __DrumMapService:getUnloadedMatchingZoneIndex(keyGroup, monoSampleName)
	local zones = keyGroup:getZones()
	for m, zone in pairs(zones) do
		local sampleName = self:getSamplerFileName(zone:getSampleName())
		if not zone:isSampleLoaded() and sampleName == monoSampleName then
			return m
		end
	end
	return 0
end


function __DrumMapService:getFloppyUsagePercent()
	return (self.drumMap:getCurrentFloppyUsage() / MAX_FLOPPY_SIZE) * 100
end

function __DrumMapService:updateDrumMap(sl)
	local keyGroups = self.drumMap:getKeyGroups()
	local list = sl:getSampleList()
	local stereoSampleList = self:generateStereoSampleList(list)
	for k, stereoSample in pairs(stereoSampleList) do
		for l, keyGroup in pairs(keyGroups) do
			local matchingZoneIndex = 0
			if type(stereoSample) == "string" then
				-- Mono sample
				--log:fine("[new] Mono sample %s", stereoSample)
				matchingZoneIndex = self:getUnloadedMatchingZoneIndex(keyGroup, stereoSample)
			else
				--log:fine("[new] Stereo sample %s, %s %s", stereoSample[1], stereoSample[2], string.sub(stereoSample[1], 1, #stereoSample[1] - 2))
				-- Stereo sample
				matchingZoneIndex = self:getUnloadedMatchingZoneIndex(keyGroup, string.sub(stereoSample[1], 1, #stereoSample[1] - 2))
			end
			if matchingZoneIndex > 0 then
				self.drumMap:replaceKeyGroupZoneWithSample(l, matchingZoneIndex, stereoSample)
				break
			end
		end
	end
end

function __DrumMapService:isValidSampleFile(file)
	return file:getFileExtension() == ".wav"
end

function __DrumMapService:assignSample()
	local selectedSample = self.drumMap:getSelectedSample()
	if type(selectedSample) == "string" then
		-- __Sample is already on S2k
		self.drumMap:addSampleToSelectedKeyGroup(selectedSample)
	else
		-- __Sample is on host
		local sampleSize = getFileSize(selectedSample)
		if sampleSize > MAX_FLOPPY_SIZE then
			return "Samples larger than one floppy are not\nsupported."
		end
	
		log:fine("Assigning sample...")
		local numSamplesOnKg = self.drumMap:getNumSamplesOnSelectedKeyGroup()
		if numSamplesOnKg == 4 then
			return "You can only add four samples per key group"
		end

		local numFloppies = self.drumMap:getNumFloppies()
		if numFloppies == 0 then
			self.drumMap:addNewFloppy()
		end

		log:fine("current usage: %d, sampleSize: %d", self.drumMap:getCurrentFloppyUsage(), sampleSize)
		if self.drumMap:getCurrentFloppyUsage() + sampleSize > MAX_FLOPPY_SIZE then
			self.drumMap:addNewFloppy()
		end
		
		self.drumMap:insertToCurrentFloppy(selectedSample)
		self.drumMap:setCurrentFloppyUsage(self.drumMap:getCurrentFloppyUsage() + sampleSize)
		self.drumMap:addFileToSelectedKeyGroup(selectedSample)
	end

	return "Transfer samples to sampler by pressing \"Launch\""
end

function DrumMapService()
	return __DrumMapService:new()
end
