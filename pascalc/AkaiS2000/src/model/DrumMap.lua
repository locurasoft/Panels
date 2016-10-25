require("Dispatcher")
require("Logger")
require("model/KeyGroup")
require("model/Zone")
require("message/KdataMsg")

local log = Logger("DrumMap")

DrumMap = {}
DrumMap.__index = DrumMap

setmetatable(DrumMap, {
  __index = Dispatcher, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function DrumMap:_init()
  Dispatcher._init(self)
  self.keyRanges = {}
  for i = 0,15 do
    table.insert(self.keyRanges, {i, i})
  end

  self.keyGroups = {}
  self.floppyList = {}
  self.selectedSample = nil
  self.selectedKg = nil
  self.currentFloppyUsage = 0
  self.numKgs = 16
  self[LUA_CONTRUCTOR_NAME] = "DrumMap"
end

function DrumMap:setSelectedSample(selectedSample)
  self.selectedSample = selectedSample
  self:notifyListeners()
end

---
-- @function [parent=#DrumMap] setSelectedKeyGroup
--
-- Accepts either string like drumMap-[integer] or just the integer
function DrumMap:setSelectedKeyGroup(selectedKg)
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

function DrumMap:isSelectedKeyGroup(padName)
  if type(padName) == "string" then
    padName = tonumber(string.sub(padName, string.find(padName, "-") + 1, #padName))
  end
  return padName == self.selectedKg
end

function DrumMap:getSelectedSample()
  return self.selectedSample
end

function DrumMap:getSelectedKeyGroup()
  return self.selectedKg
end

function DrumMap:isReadyForAssignment()
  return self.selectedSample ~= nil and self.selectedKg ~= nil
end

function DrumMap:getCurrentFloppyUsage()
  return self.currentFloppyUsage
end

function DrumMap:setCurrentFloppyUsage(currentFloppyUsage)
  self.currentFloppyUsage = currentFloppyUsage
  self:notifyListeners()
end

function DrumMap:getNumFloppies()
  return table.getn(self.floppyList)
end

function DrumMap:addNewFloppy()
  log:info("add new floppy: %d", self:getNumFloppies())
  local floppy = {}
  table.insert(self.floppyList, floppy)
  self.currentFloppyUsage = 0
  return floppy
end

function DrumMap:insertToCurrentFloppy(sample)
  local floppy = self:getFloppy(self:getNumFloppies())
  table.insert(floppy, sample)
end

function DrumMap:getFloppy(index)
  return self.floppyList[index]
end

function DrumMap:retrieveNextFloppy()
  return table.remove(self.floppyList)
end

function DrumMap:setNumKeyGroups(numKeyGroups)
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
  self.numKgs = numKeyGroups
  self:notifyListeners()
end

function DrumMap:getKeyGroups()
  return self.keyGroups
end

function DrumMap:getNumKeyGroups()
  return table.getn(self.keyGroups)
end

function DrumMap:addSampleToSelectedKeyGroup(sample)
  local selectedKeyGroup = self.keyGroups[self.selectedKg]
  assert(selectedKeyGroup:numZones() < 4, "A key group can only contain 4 zones")
  selectedKeyGroup:addSampleZone(sample)
  self:notifyListeners()
end

function DrumMap:addFileToSelectedKeyGroup(file)
  local selectedKeyGroup = self.keyGroups[self.selectedKg]
  assert(selectedKeyGroup:numZones() < 4, "A key group can only contain 4 zones")
  selectedKeyGroup:addFileZone(file)
  self:notifyListeners()
end

function DrumMap:getNumSamplesOnSelectedKeyGroup()
  local selectedKeyGroup = self.keyGroups[self.selectedKg]
  if selectedKeyGroup == nil then
    return 0
  else
    return selectedKeyGroup:numZones()
  end
end

function DrumMap:getSamplesOfKeyGroup(kgIndex)
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

function DrumMap:clearSelectedKeyGroup()
  local selectedKeyGroup = self.keyGroups[self.selectedKg]
  selectedKeyGroup:removeAllZones()
  self:notifyListeners()
end

function DrumMap:resetKeyRange(index)
  local defaultValue = index - 1
  local kg = self.keyGroups[index]
  kg:setLowNote(defaultValue)
  kg:setHighNote(defaultValue)
  self:notifyListeners()
end

function DrumMap:resetSelectedKeyRange()
  if self.selectedKg == nil then
    log:fine("DrumMap:resetSelectedKeyRange - No pad selected")
    return
  end
  self:resetKeyRange(self.selectedKg)
end

function DrumMap:setKeyRange(index, value)
  if type(index) == "string" then
    index = tonumber(index)
  end

  -- 1 signifies low key
  -- 2 signifies high key
  local kg = self.keyGroups[self.selectedKg]
  if index == 1 then
    kg:setLowNote(value)
  elseif index == 2 then
    kg:setHighNote(value)
  else
    assert(false, string.format("Weird high/low index %d", index))
  end
  
  self:notifyListeners()
end

function DrumMap:getSelectedKeyRangeValues()
  if self.selectedKg == nil then
    return { 0, 0 }
  else
    local kg = self.keyGroups[self.selectedKg]
    return { kg:getParamValue("LONOTE"), kg:getParamValue("HINOTE") }
  end
end

function DrumMap:resetAllRanges()
  for i = 1, self:getNumKeyGroups() do
    self:resetKeyRange(i)
  end
  self:notifyListeners()
end

function DrumMap:replaceKeyGroupZoneWithSample(keyGroupIndex, zoneIndex, stereoSample)
  local keyGroup = self.keyGroups[keyGroupIndex]
  if type(stereoSample) == "string" then
    -- Mono sample
    keyGroup:replaceWithMonoSample(zoneIndex, stereoSample)
  else
    -- Stereo sample
    keyGroup:replaceZoneWithStereoSample(zoneIndex, stereoSample[1], stereoSample[2])
  end
  self:notifyListeners()
end

function DrumMap:hasLoadedAllSamples()
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

function DrumMap:isClear()
  for k,keyGroup in pairs(self.keyGroups) do
    return false
  end
  return true
end

function DrumMap:resetDrumMap()
  self.currentFloppyUsage = 0
  self.keyGroups = {}
  self.floppyList = {}
  log:info("self.numKgs %d", self.numKgs)
  self:setNumKeyGroups(self.numKgs)
end

-- Used for floppy image selection
function DrumMap:getLaunchButtonState()
  if floppyImgPath == nil then
    if self:isReadyForAssignment() then
      return ""
    else
      return "Select a sample and a key group"
    end
  else
    if self.selectedKg ~= nil or self.selectedSample ~= nil then
      return "You cannot load both an image and samples.\nPlease clear some data"
    else
      return ""
    end
  end
end
