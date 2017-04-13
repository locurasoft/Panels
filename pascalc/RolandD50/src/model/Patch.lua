require("LuaObject")
require("Logger")
require("lutils")

local SPECIAL_OFFSETS = {[228]=50, [257]=50, [292]=50, [407]=24, [408]=50, [409]=50, [406]=24, [411]=12, [145]=50, [146]=50, [147]=50, [148]=50, [149]=50, [166]=12, [169]=12, [1]=50, [36]=50, [65]=50, [100]=50, [337]=50, [338]=50, [339]=50, [340]=50, [341]=50, [358]=12, [361]=12, [193]=50, [17]=7, [152]=7, [53]=7, [34]=7, [9]=7, [12]=7, [117]=7, [81]=7, [98]=7, [73]=7, [76]=7, [344]=7, [245]=7, [209]=7, [226]=7, [201]=7, [204]=7, [309]=7, [273]=7, [290]=7, [265]=7, [268]=7}
local PATCH_NAME_OFFSET = 384
local PATCH_NAME_LENGTH = 18

local UPPER_TONE_OFFSET = 128
local LOWER_TONE_OFFSET = 320
local TONE_NAME_LENGTH = 10

local UpperPartialSelectIndex = 174
local LowerPartialSelectIndex = 366

local Voice_HeaderSize = 8
local Voice_FooterSize = 2

local log = Logger("Patch")

Patch = {}
Patch.__index = Patch

setmetatable(Patch, {
  __index = LuaObject, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

local getPartial1Value = function(value)
  if value - math.floor(value / 2) * 2 == 1 then
    return 1
  else
    return 0
  end
end

local getPartial2Value = function(value)
  if value > 1 then
    return 1
  else
    return 0
  end
end

function Patch:_init(patchData)
  LuaObject._init(self)

  if patchData == nil then
    self.data  = MemoryBlock(Voice_singleSize, true)
  else
  end
end

function Patch:setValue(offset, value)
  if SPECIAL_OFFSETS[offset] ~= nil then
    value = value + SPECIAL_OFFSETS[offset]
  end
  self.data:setByte(offset, value)
end

function Patch:getValue(offset)
  local value = self.data:getByte(offset)
  if SPECIAL_OFFSETS[offset] ~= nil then
    value = value - SPECIAL_OFFSETS[offset]
  end
  return value
end

function Patch:getData()
  return self.data
end

function Patch:getSize()
  return self.data:getSize()
end

function Patch:getPatchName()
  return patchService:getPatchName(self.data, PATCH_NAME_OFFSET, PATCH_NAME_LENGTH)
end

function Patch:getUpperToneName()
  return patchService:getPatchName(self.data, UPPER_TONE_OFFSET, TONE_NAME_LENGTH)
end

function Patch:getLowerToneName()
  return patchService:getPatchName(self.data, LOWER_TONE_OFFSET, TONE_NAME_LENGTH)
end

function Patch:getUpperPartial1Value()
  return getPartial1Value(self.data:getByte(UpperPartialSelectIndex))
end

function Patch:getUpperPartial2Value()
  return getPartial2Value(self.data:getByte(UpperPartialSelectIndex))
end

function Patch:getLowerPartial1Value()
  return getPartial1Value(self.data:getByte(LowerPartialSelectIndex))
end

function Patch:getLowerPartial2Value()
  return getPartial2Value(self.data:getByte(LowerPartialSelectIndex))
end

function Patch:setUpperPartialValue(p1, p2)
  patch:setValue(UpperPartialSelectIndex, p1 + p2 * 2)
end

function Patch:setLowerPartialValue(p1, p2)
  patch:setValue(LowerPartialSelectIndex, p1 + p2 * 2)
end

function Patch:toStandaloneData()
  local sData = MemoryBlock(Voice_singleSize + Voice_HeaderSize + Voice_FooterSize, true)
  sData:copyFrom(Voice_Header, 0, Voice_HeaderSize)
  sData:copyFrom(Voice_Footer, Voice_singleSize + Voice_HeaderSize, Voice_FooterSize)
  sData:copyFrom(self.data, Voice_HeaderSize, self.data:getSize())

  local cs = midiService:calculateChecksum(sData, Voice_singleSize + 3)
  sData:setByte(sData:getSize() - 2, cs)
  return sData
end

function Patch:toSyxMsg()
	return D50SyxMsg(self.data)
end
