require("Dispatcher")
require("Logger")

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

KeyGroup = {}
KeyGroup.__index = KeyGroup

setmetatable(KeyGroup, {
  __index = Dispatcher, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function KeyGroup:_init()
  Dispatcher._init(self)
  self.kdata = data or KdataMsg()
  self.zones = {}
  self.updating = false
  self[LUA_CONTRUCTOR_NAME] = "KeyGroup"
end

function KeyGroup:numZones()
  return #self.zones
end

function KeyGroup:getZones()
  return self.zones
end

function KeyGroup:removeAllZones()
  self.zones = {}
  for i = 1, 4 do
    self.kdata:storeNibbles(string.format("VLOUD%d", i), midiService:toNibbles(0))
    self.kdata:storeNibbles(string.format("VPANO%d", i), midiService:toNibbles(50))
  end
end

function KeyGroup:storeParamEdit(khead)
  if self.updating then
    return
  end
  self.kdata:storeKhead(khead)
end

function KeyGroup:setLowNote(lowNote)
  local nibbles = midiService:toNibbles(lowNote)
  self.kdata:storeNibbles("LONOTE", nibbles)
end

function KeyGroup:setHighNote(highNote)
  local nibbles = midiService:toNibbles(highNote)
  self.kdata:storeNibbles("HINOTE", nibbles)
end

function KeyGroup:getParamValue(blockId)
  return self.kdata:getKdataValue(blockId)
end

function KeyGroup:insertZone(zoneIndex, theZone)
  table.insert(self.zones, zoneIndex, theZone)
end

function KeyGroup:addSampleZone(sampleName)
  local sampleZone = Zone()
  sampleZone:setSample(sampleName)
  self:insertZone(#self.zones + 1, sampleZone)
  return sampleZone
end

function KeyGroup:addFileZone(file)
  local fileZone = Zone()
  fileZone:setFile(file)
  self:insertZone(#self.zones + 1, fileZone)
  return fileZone
end

function KeyGroup:replaceZoneWithStereoSample(zoneIndex, sampleNameLeft, sampleNameRight)
  local leftZone = self.zones[zoneIndex]
  leftZone:setSample(sampleNameLeft)
  self.kdata:storeNibbles(string.format("VLOUD%d", zoneIndex), midiService:toNibbles(63))

  if self:numZones() < 4 then
    self.kdata:storeNibbles(string.format("VPANO%d", zoneIndex), midiService:toNibbles(0))

    local rightZone = Zone()
    rightZone:setSample(sampleNameRight)
    self:insertZone(zoneIndex + 1, rightZone)
    self.kdata:storeNibbles(string.format("VPANO%d", zoneIndex + 1), midiService:toNibbles(101))
    self.kdata:storeNibbles(string.format("VLOUD%d", zoneIndex + 1), midiService:toNibbles(63))
  end
end

function KeyGroup:replaceWithMonoSample(zoneIndex, sampleName)
  local zone = self.zones[zoneIndex]
  zone:setSample(sampleName)
end

function KeyGroup:setUpdating(updating)
  self.updating = updating
end

function KeyGroup:isUpdating()
  return self.updating
end

function KeyGroup:toString()
  return self.kdata:toString()
end
