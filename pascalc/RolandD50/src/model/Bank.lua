require("LuaObject")
require("Logger")
require("lutils")

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
  __index = LuaObject, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function Bank:_init(bankData)
  LuaObject._init(self)

  if bankData == nil then
    self.data  = MemoryBlock(Voice_singleSize * 64, true)
  else
    self.data = bankData
    local reverbSize = self.data:getSize() - patchDataSize
    VoiceBankData = MemoryBlock(patchDataSize, true)
    VoiceBankData:copyFrom(self.data, 0, patchDataSize)

    VoiceReverbData = MemoryBlock(reverbSize, true)
    self.data:copyTo(VoiceReverbData, patchDataSize, reverbSize)
  end
end

function Bank:getSelectedPatchIndex()
	return self.selectedPatchIndex
end

function Bank:setSelectedPatchIndex(selectedPatchIndex)
  self.selectedPatchIndex = selectedPatchIndex
end

function Bank:toStandaloneData()
  local splitData = splitData(self.data, VoiceReverbData)

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
  local splitData = splitData(self.data, VoiceReverbData)

  local msgs = {}
  for data in ipairs(splitData) do
    table.insert(msgs, D50SyxMsg(data))
  end
  return msgs
end
