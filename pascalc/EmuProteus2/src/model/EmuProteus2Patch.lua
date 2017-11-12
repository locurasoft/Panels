require("LuaObject")
require("Logger")
require("message/Proteus2SyxMsg")
require("lutils")

local log = Logger("EmuProteus2Patch")

local calculateChecksum = function(sysex, csStart, csEnd)
  local sum = 0
  for i = csStart, csEnd do
    sum = sum + sysex:getByte(i)
  end
  return sum % 128
end

EmuProteus2Patch = {}
EmuProteus2Patch.__index = EmuProteus2Patch

setmetatable(EmuProteus2Patch, {
  __index = LuaObject, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function EmuProteus2Patch:_init(bankData, patchOffset)
  LuaObject._init(self)

  if bankData ~= nil then
    self.data = bankData
    self.patchOffset = patchOffset
  end
end

function EmuProteus2Patch:getValueOffset(relativeOffset)
  return self.patchOffset + relativeOffset
end

-- This method fetches the patch name from the hidden
-- char modulators and returns it as a string
function EmuProteus2Patch:getPatchName()
  local char0 = self.data:getByte(self:getValueOffset(7))
  local char1 = self.data:getByte(self:getValueOffset(9))
  local char2 = self.data:getByte(self:getValueOffset(11))
  local char3 = self.data:getByte(self:getValueOffset(13))
  local char4 = self.data:getByte(self:getValueOffset(15))
  local char5 = self.data:getByte(self:getValueOffset(17))
  local char6 = self.data:getByte(self:getValueOffset(19))
  local char7 = self.data:getByte(self:getValueOffset(21))
  local char8 = self.data:getByte(self:getValueOffset(23))
  local char9 = self.data:getByte(self:getValueOffset(25))
  local char10 = self.data:getByte(self:getValueOffset(27))
  local char11 = self.data:getByte(self:getValueOffset(29))
  return string.format("%c%c%c%c%c%c%c%c%c%c%c%c", char0, char1, char2, char3, char4, char5, char6, char7, char8, char9, char10, char11)
end

-- This method set the values of the hidden char modulators
-- to match the given name
function EmuProteus2Patch:setPatchName(patchName)
  local patchNameStart = 7

  for i = 0, 11 do
    local char = string.byte(patchName, i + 1, i + 1)
    if char == nil then
      char = 0
    end
    self.data:setByte(self:getValueOffset(i * 2 + patchNameStart), char)
  end
end

function EmuProteus2Patch:setDataByte(offset, value)
  log:warnIf(self.data:getByte(offset) ~= value, "changing byte! offset: %d from val: %.2X to val: %.2X", offset, self.data:getByte(self:getValueOffset(offset)), value)
  self.data:setByte(self:getValueOffset(offset), value)
end

function EmuProteus2Patch:setValue(index, value)
  if index == 53 or index == 89 then
    value = emuProteus2InstrumentService:c2m(value + 1)
  end

  local oldValue = value
  if value < 0 then
    value = -value
    value = bit.bnot(value)
    value = bit.band(value, 16383)
    value = value + 1
  end

  self.data:setByte(self:getValueOffset(index), value - math.floor(value / 128) * 128)
  self.data:setByte(self:getValueOffset(index + 1), math.floor(value / 128))
end

function EmuProteus2Patch:getValue(index)
  local ll = self.data:getByte(self:getValueOffset(index))
  local mm = self.data:getByte(self:getValueOffset(index + 1))
  local value = ll + (mm * 128)

  if value > 8000 then
    value = 16384 - value;
    value = -value;
  end

  if index == 53 or index == 89 then
    return emuProteus2InstrumentService:m2c(value)
  else
    return value
  end
end

function EmuProteus2Patch:toSyxMsg()
  self.data:setByte(self:getValueOffset(SINGLE_DATA_SIZE - 2), calculateChecksum(self.data, 7, 261))
  return Proteus2SyxMsg(self.data)
end
