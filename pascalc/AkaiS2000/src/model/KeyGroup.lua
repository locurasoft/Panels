require("Dispatcher")
require("Logger")

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

function KeyGroup:_init(data)
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
end

function KeyGroup:storeParamEdit(khead)
  if self.updating then
    return
  end
  self.kdata:storeKhead(khead)
end

function KeyGroup:setLowNote(lowNote)
  local nibbles = mutils.d2n(lowNote)
  self.kdata:storeNibbles("LONOTE", nibbles)
end

function KeyGroup:setHighNote(highNote)
  local nibbles = mutils.d2n(highNote)
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

  if self:numZones() < 4 then
    local rightZone = Zone()
    rightZone:setSample(sampleNameRight)
    self:insertZone(zoneIndex + 1, rightZone)
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
