local doubleByteParams = {
	["VSS1"] = true,
	["VSS2"] = true,
	["VSS3"] = true,
	["VSS4"] = true,
	["VTUNO1"] = true,
	["VTUNO2"] = true,
	["VTUNO3"] = true,
	["VTUNO4"] = true,
}

local log = Logger("KeyGroup")

__KeyGroup = Object()

function __KeyGroup:numZones()
	return #self.zones
end

function __KeyGroup:getZones()
	return self.zones
end

function __KeyGroup:storeParamEdit(khead)
	if self.updating then
		return
	end
	self.kdata:storeKhead(khead)
end

function __KeyGroup:setLowNote(lowNote)
	self.kdata:storeNibbles("LONOTE", midiSrvc:toNibbles(lowNote))
end

function __KeyGroup:setHighNote(highNote)
	self.kdata:storeNibbles("HINOTE", midiSrvc:toNibbles(highNote))
end

function __KeyGroup:getParamValue(blockId)
	return self.kdata:getKdataValue(blockId)
end

function __KeyGroup:insertZone(zoneIndex, theZone)
	table.insert(self.zones, zoneIndex, theZone)		
end

function __KeyGroup:addSampleZone(sampleName)
	local sampleZone = Zone()
	sampleZone:setSample(sampleName)
	self:insertZone(#self.zones + 1, sampleZone)
	return sampleZone
end

function __KeyGroup:addFileZone(file)
	local fileZone = Zone()
	fileZone:setFile(file)
	self:insertZone(#self.zones + 1, fileZone)
	return fileZone
end

function __KeyGroup:replaceZoneWithStereoSample(zoneIndex, sampleNameLeft, sampleNameRight)
	local leftZone = self.zones[zoneIndex]
	leftZone:setSample(sampleNameLeft)
	self.kdata:storeNibbles(string.format("VLOUD%d", zoneIndex), midiSrvc:toNibbles(63))

	if self:numZones() < 4 then
		self.kdata:storeNibbles(string.format("VPANO%d", zoneIndex), midiSrvc:toNibbles(0))

		local rightZone = Zone()
		rightZone:setSample(sampleNameRight)
		self:insertZone(zoneIndex + 1, rightZone)
		self.kdata:storeNibbles(string.format("VPANO%d", zoneIndex + 1), midiSrvc:toNibbles(101))
		self.kdata:storeNibbles(string.format("VLOUD%d", zoneIndex + 1), midiSrvc:toNibbles(63))
	end		
end

function __KeyGroup:replaceWithMonoSample(zoneIndex, sampleName)
	local zone = self.zones[zoneIndex]
	zone:setSample(sampleNameLeft)
end

function __KeyGroup:setUpdating(updating)
	self.updating = updating
end

function __KeyGroup:isUpdating()
	return self.updating
end


function __KeyGroup:toString()
	return self.kdata:toString()
end

function KeyGroup(data)
	data = data or Kdata()
	return __KeyGroup:new{
		kdata = data,
		zones = {}, 
		updating = false,
		[LUA_CLASS_NAME] = "KeyGroup"
	}
end
