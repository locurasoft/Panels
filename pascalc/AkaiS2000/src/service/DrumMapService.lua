require("LuaObject")
require("Logger")
require("cutils")

local log = Logger("DrumMapService")
local MAX_FLOPPY_SIZE = 1400000
local MAX_SAMPLE_NAME_SIZE = 12

DrumMapService = {}
DrumMapService.__index = DrumMapService

setmetatable(DrumMapService, {
  __index = LuaObject, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function DrumMapService:_init()
  LuaObject._init(self)
end

function DrumMapService:getSamplerFileName(filename)
  local sampleName = string.upper (filename)
  if #sampleName > MAX_SAMPLE_NAME_SIZE then
    sampleName = string.sub(sampleName, 1, MAX_SAMPLE_NAME_SIZE)
  elseif #sampleName < MAX_SAMPLE_NAME_SIZE then
    sampleName = sampleName .. string.rep(" ", MAX_SAMPLE_NAME_SIZE - #sampleName)
  end
  return sampleName
end

function DrumMapService:findStereoCounterpart(sampleList, stereoPartnerName, arrayOffset)
  for k,v in pairs(sampleList) do
    if type(v) ~= "string" and v[arrayOffset] == stereoPartnerName then
      return k
    end
  end
  return -1
end

function DrumMapService:generateStereoSampleList(sampleList)
  local retVal = {}
  local leftIndex = 1
  local rightIndex = 2

  for k,name in pairs(sampleList) do
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

function DrumMapService:getUnloadedMatchingZoneIndex(keyGroup, monoSampleName)
  local zones = keyGroup:getZones()
  for m, zone in pairs(zones) do
    local sampleName = self:getSamplerFileName(zone:getSampleName())
    local start, length = string.find(sampleName, monoSampleName, 1, true)
    if not zone:isSampleLoaded() and start == 1 and length == monoSampleName:len() then
      return m
    end
  end
  return 0
end

function DrumMapService:getFloppyUsagePercent(drumMap)
  return (drumMap:getCurrentFloppyUsage() / MAX_FLOPPY_SIZE) * 100
end

function DrumMapService:isValidSampleFile(file)
  return file:getFileExtension() == ".wav"
end

function DrumMapService:assignSample(drumMap)
  assert(drumMap:isReadyForAssignment(), "Select a sample and a key group.")

  local numSamplesOnKg = drumMap:getNumSamplesOnSelectedKeyGroup()
  assert(numSamplesOnKg < 4, "You can only add four samples per key group")

  local selectedSample = drumMap:getSelectedSample()
  if type(selectedSample) == "string" then
    -- Sample is already on S2k
    log:info("Assigning sample %s...", selectedSample)
    drumMap:addSampleToSelectedKeyGroup(selectedSample)
  else
    log:info("Assigning sample %s...", selectedSample:getFullPathName())
    
    -- Sample is on host
    local sampleSize = cutils.getFileSize(selectedSample)
    assert(sampleSize <= MAX_FLOPPY_SIZE, "Samples larger than one floppy are not\nsupported.")

    local numFloppies = drumMap:getNumFloppies()
    if numFloppies == 0 or drumMap:getCurrentFloppyUsage() + sampleSize > MAX_FLOPPY_SIZE then
      drumMap:addNewFloppy()
    end

    drumMap:insertToCurrentFloppy(selectedSample)
    drumMap:setCurrentFloppyUsage(drumMap:getCurrentFloppyUsage() + sampleSize)
    drumMap:addFileToSelectedKeyGroup(selectedSample)
  end
end

function DrumMapService:updateDrumMapSamples(drumMap, sampleList)
  local keyGroups = drumMap:getKeyGroups()
  local list = sampleList:getSampleList()
  local stereoSampleList = self:generateStereoSampleList(list)
  for k, stereoSample in pairs(stereoSampleList) do
    for l, keyGroup in pairs(keyGroups) do
      local matchingZoneIndex = 0
      if type(stereoSample) == "string" then
        -- Mono sample
        matchingZoneIndex = self:getUnloadedMatchingZoneIndex(keyGroup, stereoSample)
      else
        -- Stereo sample
        matchingZoneIndex = self:getUnloadedMatchingZoneIndex(keyGroup, string.sub(stereoSample[1], 1, #stereoSample[1] - 2))
      end
      if matchingZoneIndex > 0 then
        drumMap:replaceKeyGroupZoneWithSample(l, matchingZoneIndex, stereoSample)
      end
    end
  end
end
