require("AbstractBank")
require("SyxMsg")
require("model/YamahaCS1xPatch")
require("message/CS1xSyxMsg")
require("Logger")
require("lutils")

local log = Logger("YamahaCS1xBank")

local getPerformanceFromBank = function (perfIndex)
  if VoiceBankData == nil or table.getn(VoiceBankData) == 0 then
    --console("Cannot retreive performance from empty bank")
    return nil
  end

  local start = perfIndex * 7
  if VoiceBankData[start] ~= nil then
    return nil
  end

  local retval = {}
  for i = start, 7 do
    table.insert(retval, VoiceBankData[i])
  end
  return retval
end

local putPerformanceToBank = function(data, index)
  if VoiceBankData == nil then
    VoiceBankData = {}
  end

  local offset = index * 7
  for i = 1, 7 do
    VoiceBankData[i + offset] = data[i]
  end
end


YamahaCS1xBank = {}
YamahaCS1xBank.__index = YamahaCS1xBank

setmetatable(YamahaCS1xBank, {
  __index = AbstractBank, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

local getPatchStart = function(patchNum)
  return Voice_dxSinglePackedSize * patchNum + Voice_dxSysexHeaderSize
end

local getPatch = function(bankData, patchNum)
  local patchOffset = getPatchStart(patchNum)

  local sysex = MemoryBlock(Voice_singleSize, true)
  sysex:setByte(0, 0xF0)
  sysex:setByte(1, 0x43)
  sysex:setByte(2, 0x00)
  sysex:setByte(3, 0x00)
  sysex:setByte(4, 0x01)
  sysex:setByte(5, 0x1B)
  for i = 0, (6-1) do
    local bankOpOffset = i * 17
    local patchOpOffset = i * 21
    sysex:setByte(Voice_dxSysexHeaderSize + 0 + patchOpOffset, bankData:getByte(patchOffset + 0 + bankOpOffset))
    sysex:setByte(Voice_dxSysexHeaderSize + 1 + patchOpOffset, bankData:getByte(patchOffset + 1 + bankOpOffset))
    sysex:setByte(Voice_dxSysexHeaderSize + 2 + patchOpOffset, bankData:getByte(patchOffset + 2 + bankOpOffset))
    sysex:setByte(Voice_dxSysexHeaderSize + 3 + patchOpOffset, bankData:getByte(patchOffset + 3 + bankOpOffset))
    sysex:setByte(Voice_dxSysexHeaderSize + 4 + patchOpOffset, bankData:getByte(patchOffset + 4 + bankOpOffset))
    sysex:setByte(Voice_dxSysexHeaderSize + 5 + patchOpOffset, bankData:getByte(patchOffset + 5 + bankOpOffset))
    sysex:setByte(Voice_dxSysexHeaderSize + 6 + patchOpOffset, bankData:getByte(patchOffset + 6 + bankOpOffset))
    sysex:setByte(Voice_dxSysexHeaderSize + 7 + patchOpOffset, bankData:getByte(patchOffset + 7 + bankOpOffset))
    sysex:setByte(Voice_dxSysexHeaderSize + 8 + patchOpOffset, bankData:getByte(patchOffset + 8 + bankOpOffset))
    sysex:setByte(Voice_dxSysexHeaderSize + 9 + patchOpOffset, bankData:getByte(patchOffset + 9 + bankOpOffset))
    sysex:setByte(Voice_dxSysexHeaderSize + 10 + patchOpOffset, bankData:getByte(patchOffset + 10 + bankOpOffset))
    sysex:setByte(Voice_dxSysexHeaderSize + 11 + patchOpOffset, bit.band(bankData:getByte(patchOffset + 11 + bankOpOffset), 3))
    sysex:setByte(Voice_dxSysexHeaderSize + 12 + patchOpOffset, math.floor(bit.band(bankData:getByte(patchOffset + 11 + bankOpOffset), 12) / 4))
    sysex:setByte(Voice_dxSysexHeaderSize + 13 + patchOpOffset, bit.band(bankData:getByte(patchOffset + 12 + bankOpOffset), 7))
    sysex:setByte(Voice_dxSysexHeaderSize + 14 + patchOpOffset, bit.band(bankData:getByte(patchOffset + 13 + bankOpOffset), 3))
    sysex:setByte(Voice_dxSysexHeaderSize + 15 + patchOpOffset, math.floor(bit.band(bankData:getByte(patchOffset + 13 + bankOpOffset), 28) / 4))
    sysex:setByte(Voice_dxSysexHeaderSize + 16 + patchOpOffset, bankData:getByte(patchOffset + 14 + bankOpOffset))
    sysex:setByte(Voice_dxSysexHeaderSize + 17 + patchOpOffset, bit.band(bankData:getByte(patchOffset + 15 + bankOpOffset), 1))
    sysex:setByte(Voice_dxSysexHeaderSize + 18 + patchOpOffset, math.floor(bit.band(bankData:getByte(patchOffset + 15 + bankOpOffset), 62) / 2))
    sysex:setByte(Voice_dxSysexHeaderSize + 19 + patchOpOffset, bankData:getByte(patchOffset + 16 + bankOpOffset))
    sysex:setByte(Voice_dxSysexHeaderSize + 20 + patchOpOffset, math.floor(bit.band(bankData:getByte(patchOffset + 12 + bankOpOffset), 120) / 8))
  end

  sysex:setByte(Voice_dxSysexHeaderSize + 126, bankData:getByte(patchOffset + 102))
  sysex:setByte(Voice_dxSysexHeaderSize + 127, bankData:getByte(patchOffset + 103))
  sysex:setByte(Voice_dxSysexHeaderSize + 128, bankData:getByte(patchOffset + 104))
  sysex:setByte(Voice_dxSysexHeaderSize + 129, bankData:getByte(patchOffset + 105))
  sysex:setByte(Voice_dxSysexHeaderSize + 130, bankData:getByte(patchOffset + 106))
  sysex:setByte(Voice_dxSysexHeaderSize + 131, bankData:getByte(patchOffset + 107))
  sysex:setByte(Voice_dxSysexHeaderSize + 132, bankData:getByte(patchOffset + 108))
  sysex:setByte(Voice_dxSysexHeaderSize + 133, bankData:getByte(patchOffset + 109))
  sysex:setByte(Voice_dxSysexHeaderSize + 134, bit.band(bankData:getByte(patchOffset + 110), 31))
  sysex:setByte(Voice_dxSysexHeaderSize + 135, bit.band(bankData:getByte(patchOffset + 111), 7))
  sysex:setByte(Voice_dxSysexHeaderSize + 136, math.floor(bit.band(bankData:getByte(patchOffset + 111), 8) / 8))
  sysex:setByte(Voice_dxSysexHeaderSize + 137, bankData:getByte(patchOffset + 112))
  sysex:setByte(Voice_dxSysexHeaderSize + 138, bankData:getByte(patchOffset + 113))
  sysex:setByte(Voice_dxSysexHeaderSize + 139, bankData:getByte(patchOffset + 114))
  sysex:setByte(Voice_dxSysexHeaderSize + 140, bankData:getByte(patchOffset + 115))
  sysex:setByte(Voice_dxSysexHeaderSize + 141, bit.band(bankData:getByte(patchOffset + 116), 1))
  sysex:setByte(Voice_dxSysexHeaderSize + 142, math.floor(bit.band(bankData:getByte(patchOffset + 116), 14) / 2))
  sysex:setByte(Voice_dxSysexHeaderSize + 143, math.floor(bit.band(bankData:getByte(patchOffset + 116), 112) / 16))
  sysex:setByte(Voice_dxSysexHeaderSize + 144, bankData:getByte(patchOffset + 117))
  sysex:setByte(Voice_dxSysexHeaderSize + 145, bankData:getByte(patchOffset + 118))
  sysex:setByte(Voice_dxSysexHeaderSize + 146, bankData:getByte(patchOffset + 119))
  sysex:setByte(Voice_dxSysexHeaderSize + 147, bankData:getByte(patchOffset + 120))
  sysex:setByte(Voice_dxSysexHeaderSize + 148, bankData:getByte(patchOffset + 121))
  sysex:setByte(Voice_dxSysexHeaderSize + 149, bankData:getByte(patchOffset + 122))
  sysex:setByte(Voice_dxSysexHeaderSize + 150, bankData:getByte(patchOffset + 123))
  sysex:setByte(Voice_dxSysexHeaderSize + 151, bankData:getByte(patchOffset + 124))
  sysex:setByte(Voice_dxSysexHeaderSize + 152, bankData:getByte(patchOffset + 125))
  sysex:setByte(Voice_dxSysexHeaderSize + 153, bankData:getByte(patchOffset + 126))
  sysex:setByte(Voice_dxSysexHeaderSize + 154, bankData:getByte(patchOffset + 127))
  sysex:setByte(Voice_singleSize - 1, 0xF7)

  return sysex
end

local putPatch = function(patch, patchNum, bankData)
  local patchOffset = getPatchStart(patchNum)
  for i = 0, (6-1) do
    local bankOpOffset = i * 17
    local patchOpOffset = i * 21
    bankData:setByte(patchOffset + 0 + bankOpOffset, patch.data:getByte(Voice_dxSysexHeaderSize + 0 + patchOpOffset))
    bankData:setByte(patchOffset + 1 + bankOpOffset, patch.data:getByte(Voice_dxSysexHeaderSize + 1 + patchOpOffset))
    bankData:setByte(patchOffset + 2 + bankOpOffset, patch.data:getByte(Voice_dxSysexHeaderSize + 2 + patchOpOffset))
    bankData:setByte(patchOffset + 3 + bankOpOffset, patch.data:getByte(Voice_dxSysexHeaderSize + 3 + patchOpOffset))
    bankData:setByte(patchOffset + 4 + bankOpOffset, patch.data:getByte(Voice_dxSysexHeaderSize + 4 + patchOpOffset))
    bankData:setByte(patchOffset + 5 + bankOpOffset, patch.data:getByte(Voice_dxSysexHeaderSize + 5 + patchOpOffset))
    bankData:setByte(patchOffset + Voice_dxSysexHeaderSize + bankOpOffset, patch.data:getByte(Voice_dxSysexHeaderSize + 6 + patchOpOffset))
    bankData:setByte(patchOffset + 7 + bankOpOffset, patch.data:getByte(Voice_dxSysexHeaderSize + 7 + patchOpOffset))
    bankData:setByte(patchOffset + 8 + bankOpOffset, patch.data:getByte(Voice_dxSysexHeaderSize + 8 + patchOpOffset))
    bankData:setByte(patchOffset + 9 + bankOpOffset, patch.data:getByte(Voice_dxSysexHeaderSize + 9 + patchOpOffset))
    bankData:setByte(patchOffset + 10 + bankOpOffset, patch.data:getByte(Voice_dxSysexHeaderSize + 10 + patchOpOffset))
    bankData:setByte(patchOffset + 11 + bankOpOffset, (patch.data:getByte(Voice_dxSysexHeaderSize + 12 + patchOpOffset) * 4 + patch.data:getByte(Voice_dxSysexHeaderSize + 11 + patchOpOffset)))
    bankData:setByte(patchOffset + 12 + bankOpOffset, (patch.data:getByte(Voice_dxSysexHeaderSize + 20 + patchOpOffset) * 8 + patch.data:getByte(Voice_dxSysexHeaderSize + 13 + patchOpOffset)))
    bankData:setByte(patchOffset + 13 + bankOpOffset, (patch.data:getByte(Voice_dxSysexHeaderSize + 15 + patchOpOffset) * 4 + patch.data:getByte(Voice_dxSysexHeaderSize + 14 + patchOpOffset)))
    bankData:setByte(patchOffset + 14 + bankOpOffset, patch.data:getByte(Voice_dxSysexHeaderSize + 16 + patchOpOffset))
    bankData:setByte(patchOffset + 15 + bankOpOffset, (patch.data:getByte(Voice_dxSysexHeaderSize + 18 + patchOpOffset) * 2 + patch.data:getByte(Voice_dxSysexHeaderSize + 17 + patchOpOffset)))
    bankData:setByte(patchOffset + 16 + bankOpOffset, patch.data:getByte(Voice_dxSysexHeaderSize + 19 + patchOpOffset))
  end
  bankData:setByte(patchOffset + 102, patch.data:getByte(Voice_dxSysexHeaderSize + 126))
  bankData:setByte(patchOffset + 103, patch.data:getByte(Voice_dxSysexHeaderSize + 127))
  bankData:setByte(patchOffset + 104, patch.data:getByte(Voice_dxSysexHeaderSize + 128))
  bankData:setByte(patchOffset + 105, patch.data:getByte(Voice_dxSysexHeaderSize + 129))
  bankData:setByte(patchOffset + 106, patch.data:getByte(Voice_dxSysexHeaderSize + 130))
  bankData:setByte(patchOffset + 107, patch.data:getByte(Voice_dxSysexHeaderSize + 131))
  bankData:setByte(patchOffset + 108, patch.data:getByte(Voice_dxSysexHeaderSize + 132))
  bankData:setByte(patchOffset + 109, patch.data:getByte(Voice_dxSysexHeaderSize + 133))
  bankData:setByte(patchOffset + 110, patch.data:getByte(Voice_dxSysexHeaderSize + 134))
  bankData:setByte(patchOffset + 111, (patch.data:getByte(Voice_dxSysexHeaderSize + 136) * 8 + patch.data:getByte(Voice_dxSysexHeaderSize + 135)))
  bankData:setByte(patchOffset + 112, patch.data:getByte(Voice_dxSysexHeaderSize + 137))
  bankData:setByte(patchOffset + 113, patch.data:getByte(Voice_dxSysexHeaderSize + 138))
  bankData:setByte(patchOffset + 114, patch.data:getByte(Voice_dxSysexHeaderSize + 139))
  bankData:setByte(patchOffset + 115, patch.data:getByte(Voice_dxSysexHeaderSize + 140))
  bankData:setByte(patchOffset + 116, (patch.data:getByte(Voice_dxSysexHeaderSize + 143) * 16 + patch.data:getByte(Voice_dxSysexHeaderSize + 142) * 2 + patch.data:getByte(Voice_dxSysexHeaderSize + 141)))
  bankData:setByte(patchOffset + 117, patch.data:getByte(Voice_dxSysexHeaderSize + 144))
  bankData:setByte(patchOffset + 118, patch.data:getByte(Voice_dxSysexHeaderSize + 145))
  bankData:setByte(patchOffset + 119, patch.data:getByte(Voice_dxSysexHeaderSize + 146))
  bankData:setByte(patchOffset + 120, patch.data:getByte(Voice_dxSysexHeaderSize + 147))
  bankData:setByte(patchOffset + 121, patch.data:getByte(Voice_dxSysexHeaderSize + 148))
  bankData:setByte(patchOffset + 122, patch.data:getByte(Voice_dxSysexHeaderSize + 149))
  bankData:setByte(patchOffset + 123, patch.data:getByte(Voice_dxSysexHeaderSize + 150))
  bankData:setByte(patchOffset + 124, patch.data:getByte(Voice_dxSysexHeaderSize + 151))
  bankData:setByte(patchOffset + 125, patch.data:getByte(Voice_dxSysexHeaderSize + 152))
  bankData:setByte(patchOffset + 126, patch.data:getByte(Voice_dxSysexHeaderSize + 153))
  bankData:setByte(patchOffset + 127, patch.data:getByte(Voice_dxSysexHeaderSize + 154))
end

local compressData = function(patches, bankData)
  for i = 1, NUM_PATCHES do
    putPatch(patches[i], i - 1, bankData)
  end
  Voice_CalculateChecksum(bankData, 6, 4101, 4102)
end

function YamahaCS1xBank:_init(bankData)
  AbstractBank._init(self)

  if bankData == nil then
    self.data = MemoryBlock(PerformanceBankSize, true)

    for i = 0, NUM_PATCHES - 1 do
      table.insert(self.patches, YamahaCS1xPatch())
    end
  else
    assert(bankData:getSize() == PerformanceBankSize, string.format("Data does not contain a Yamaha CS1x bank"))
    self.data = MemoryBlock(PerformanceBankSize, false)
    self.data:copyFrom(bankData, 0, PerformanceBankSize)

    for i = 0, NUM_PATCHES - 1 do
      table.insert(self.patches, YamahaCS1xPatch(getPatch(self.data, i)))
    end
  end
end

function YamahaCS1xBank:setPatchAt(patch, index)
  table.insert(self.patches, index, patch)
  self.data:copyFrom(patch:toSyxMsg(), (index - 1) * SinglePerformanceSize, SinglePerformanceSize)
end

function YamahaCS1xBank:toStandaloneData()
  compressData(self.patches, self.data)
  return self.data
end

function YamahaCS1xBank:toSyxMessages()
  compressData(self.patches, self.data)
  return { CS1xSyxMsg(self.data) }
end
