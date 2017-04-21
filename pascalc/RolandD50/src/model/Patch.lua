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

-- This method fetches the patch name from the hidden
-- char modulators and returns it as a string
local getD50String = function(data, patchNameStart, patchNameSize)
  local name = ""
  local symbols = {" ","A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z","1","2","3","4","5","6","7","8","9","0","-"}
  for i = patchNameStart,(patchNameStart + patchNameSize - 1) do -- gets the voice name
    local midiParam = data:getByte(i)
    name = string.format("%s%s", name, symbols[midiParam + 1]) -- Lua tables are base 1 indexed
  end
  return name
end

-- This method set the values of the hidden char modulators
-- to match the given name
local setD50String = function(data, value, start, length)
  local strLength = string.len(value)
  local symbols = {[" "] = 0,["-"] = 63,["0"] = 62,["1"] = 53,["2"] = 54,["3"] = 55,["4"] = 56,["5"] = 57,["6"] = 58,["7"] = 59,["8"] = 60,["9"] = 61,["A"] = 1,["B"] = 2,["C"] = 3,["D"] = 4,["E"] = 5,["F"] = 6,["G"] = 7,["H"] = 8,["I"] = 9,["J"] = 10,["K"] = 11,["L"] = 12,["M"] = 13,["N"] = 14,["O"] = 15,["P"] = 16,["Q"] = 17,["R"] = 18,["S"] = 19,["T"] = 20,["U"] = 21,["V"] = 22,["W"] = 23,["X"] = 24,["Y"] = 25,["Z"] = 26,["a"] = 27,["b"] = 28,["c"] = 29,["d"] = 30,["e"] = 31,["f"] = 32,["g"] = 33,["h"] = 34,["i"] = 35,["j"] = 36,["k"] = 37,["l"] = 38,["m"] = 39,["n"] = 40,["o"] = 41,["p"] = 42,["q"] = 43,["r"] = 44,["s"] = 45,["t"] = 46,["u"] = 47,["v"] = 48,["w"] = 49,["x"] = 50,["y"] = 51,["z"] = 52}
  local emptyChar = symbols[" "]
  local patchNameEnd = start + length - 1
  local patchNameIndex = 0
  for i = start, patchNameEnd do
    local caracter = " "
    if strLength > patchNameIndex then
      caracter = string.sub(value, patchNameIndex + 1, patchNameIndex + 1)
    end
    data:setByte(i, symbols[caracter])
    patchNameIndex = patchNameIndex + 1
  end
end

local getPartial1Value = function(value)
  if value == 1 or value == 3 then
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

function Patch:_init(bankData, patchOffset)
  LuaObject._init(self)

  if bankData ~= nil then
    self.data = bankData
    self.patchOffset = patchOffset
  end
end

function Patch:getValueOffset(relativeOffset)
  return self.patchOffset + relativeOffset
end

function Patch:setValue(offset, value)
  if SPECIAL_OFFSETS[offset] ~= nil then
    value = value + SPECIAL_OFFSETS[offset]
  end
  self.data:setByte(self:getValueOffset(offset), value)
end

function Patch:getValue(offset)
  local value = self.data:getByte(self:getValueOffset(offset))
  if SPECIAL_OFFSETS[offset] ~= nil then
    value = value - SPECIAL_OFFSETS[offset]
  end
  return value
end

function Patch:getPatchName()
  return getD50String(self.data, self:getValueOffset(PATCH_NAME_OFFSET), PATCH_NAME_LENGTH)
end

function Patch:getUpperToneName()
  return getD50String(self.data, self:getValueOffset(UPPER_TONE_OFFSET), TONE_NAME_LENGTH)
end

function Patch:getLowerToneName()
  return getD50String(self.data, self:getValueOffset(LOWER_TONE_OFFSET), TONE_NAME_LENGTH)
end

function Patch:setPatchName(value)
  return setD50String(self.data, value, self:getValueOffset(PATCH_NAME_OFFSET), PATCH_NAME_LENGTH)
end

function Patch:setUpperToneName(value)
  return setD50String(self.data, value, self:getValueOffset(UPPER_TONE_OFFSET), TONE_NAME_LENGTH)
end

function Patch:setLowerToneName(value)
  return setD50String(self.data, value, self:getValueOffset(LOWER_TONE_OFFSET), TONE_NAME_LENGTH)
end

function Patch:getUpperPartial1Value()
  return getPartial1Value(self.data:getByte(self:getValueOffset(UpperPartialSelectIndex)))
end

function Patch:getUpperPartial2Value()
  return getPartial2Value(self.data:getByte(self:getValueOffset(UpperPartialSelectIndex)))
end

function Patch:getLowerPartial1Value()
  return getPartial1Value(self.data:getByte(self:getValueOffset(LowerPartialSelectIndex)))
end

function Patch:getLowerPartial2Value()
  return getPartial2Value(self.data:getByte(self:getValueOffset(LowerPartialSelectIndex)))
end

function Patch:setUpperPartialValue(p1, p2)
  self:setValue(UpperPartialSelectIndex, p1 + p2 * 2)
end

function Patch:setLowerPartialValue(p1, p2)
  self:setValue(LowerPartialSelectIndex, p1 + p2 * 2)
end

function Patch:toStandaloneData()
  local sData = MemoryBlock(Voice_singleSize + Voice_HeaderSize + Voice_FooterSize, true)
  local tmp = MemoryBlock(Voice_singleSize, true)
  sData:copyFrom(Voice_Header, 0, Voice_HeaderSize)
  sData:copyFrom(Voice_Footer, Voice_singleSize + Voice_HeaderSize, Voice_FooterSize)
  self.data:copyTo(tmp, Voice_HeaderSize + self.patchOffset, Voice_singleSize)
  sData:copyFrom(tmp, Voice_HeaderSize, Voice_singleSize)
  
  local cs = midiService:calculateChecksum(sData, Voice_singleSize + 3)
  sData:setByte(sData:getSize() - 2, cs)
  return sData
end

function Patch:toSyxMsg()
  return D50SyxMsg(self.data)
end
