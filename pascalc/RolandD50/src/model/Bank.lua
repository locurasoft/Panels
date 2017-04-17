require("Dispatcher")
require("model/Patch")
require("Logger")
require("lutils")

Voice_singleSize = 448

local BANK_BUFFER_SIZE = 28672

local log = Logger("Bank")

local splitData = function(bankData, reverbData)
  local totalData = MemoryBlock(bankData:getSize() + reverbData:getSize(), true)
  totalData:copyFrom(bankData, 0, bankData:getSize())

  totalData:copyFrom(reverbData, bankData:getSize(), reverbData:getSize())

  return midiService:splitIntoSysexMessages(totalData)
end

Bank = {}
Bank.__index = Bank

setmetatable(Bank, {
  __index = Dispatcher, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function Bank:_init(bankData)
  Dispatcher._init(self)

  self.selectedPatchIndex = 0
  self.patches = {}
  if bankData == nil then
    self.data = MemoryBlock(BANK_BUFFER_SIZE, true)

    for i = 0, 63 do
      local p = Patch(self.data, i * Voice_singleSize)
      p:setPatchName("NEW PATCH")
      table.insert(self.patches, p)
    end
  else
    local data = midiService:trimSyxData(bankData)
    assert(data:getSize() ~= Voice_singleSize * 64, string.format("Data does not contain a Roland D50 bank"))

    local reverbSize = self.data:getSize() - patchDataSize
    self.data = MemoryBlock(patchDataSize, true)
    self.data:copyFrom(bankData, 0, patchDataSize)

    self.VoiceReverbData = MemoryBlock(reverbSize, true)
    bankData:copyTo(self.VoiceReverbData, patchDataSize, reverbSize)

    for i = 0, 63 do
      table.insert(self.patches, Patch(self.data, i * Voice_singleSize))
    end
  end
end

function Bank:getSelectedPatchIndex()
  return self.selectedPatchIndex
end

function Bank:getSelectedPatch()
  return self.patches[self.selectedPatchIndex + 1]
end

function Bank:selectPatch(patchIndex)
  self.selectedPatchIndex = patchIndex
end

function Bank:isSelectedPatch(patchIndex)
  return self.selectedPatchIndex == patchIndex
end

function Bank:setSelectedPatchIndex(selectedPatchIndex)
  self.selectedPatchIndex = selectedPatchIndex
end

function Bank:toStandaloneData()
  local splitData = splitData(self.data, self.VoiceReverbData)

  local splitDataSize = 0
  for i, data in ipairs(splitData) do
    splitDataSize = splitDataSize + data:getSize()
  end

  local dataToWrite = MemoryBlock(splitDataSize, true)
  local destinationOffset = 0
  for i, data in ipairs(splitData) do
    local dataSize = data:getSize()
    dataToWrite:copyFrom(data, destinationOffset, dataSize)
    destinationOffset = destinationOffset + dataSize
  end
  return dataToWrite
end

function Bank:toSyxMessages()
  local splitData = splitData(self.data, self.VoiceReverbData)

  local msgs = {}
  for data in ipairs(splitData) do
    table.insert(msgs, D50SyxMsg(data))
  end
  return msgs
end

function Bank:getNumberedPatchNamesList()
  local patchNames = ""
  for i = 0, 63 do
    if i > 0 then
      patchNames = string.format("%s\n", patchNames)
    end
    patchNames = string.format("%s%d %s=%d", patchNames, i, self.patches[i + 1]:getPatchName(), i)
  end
  return patchNames:gsub("'", "")
end
