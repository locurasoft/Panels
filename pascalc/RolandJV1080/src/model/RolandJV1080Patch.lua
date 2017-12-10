require("LuaObject")
require("Logger")
require("lutils")

local log = Logger("RolandJV1080Patch")
local patchDataLeng = 0x53
local toneDataLeng = 0x8C

RolandJV1080Patch = {}
RolandJV1080Patch.__index = RolandJV1080Patch

setmetatable(RolandJV1080Patch, {
  __index = LuaObject, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function RolandJV1080Patch:_init(patchData)
  LuaObject._init(self)

  if patchData ~= nil then
    self.data = patchData
  end
end

function RolandJV1080Patch:getValueOffset(relativeOffset)
  return relativeOffset
end

-- This method fetches the patch name from the hidden
-- char modulators and returns it as a string
function RolandJV1080Patch:getPatchName()
  -- This method fetches the patch name from the hidden

  local patchName = ""
  for i = 0, 5 do
    patchName = string.format("%s%c", patchName,
      self.data:getByte(self:getValueOffset(i * 2)) + self.data:getByte(self:getValueOffset(i * 2 + 1)) * 16)
  end
  return patchName
end

-- This method set the values of the hidden char modulators
-- to match the given name
function RolandJV1080Patch:setPatchName(patchName)
  for i = 1, 6 do
    local char = patchName:byte(i, i + 1)
    if char == nil then
      char = 0
    end

    self.data:setByte(self:getValueOffset((i - 1) * 2), char % 16)
    self.data:setByte(self:getValueOffset((i - 1) * 2 + 1), math.floor(char / 16))
  end
end

function RolandJV1080Patch:setDataByte(offset, value)
  log:warnIf(self.data:getByte(offset) ~= value, "changing byte! offset: %d from val: %.2X to val: %.2X", offset, self.data:getByte(offset), value)
  self.data:setByte(offset, value)
end

function RolandJV1080Patch:setValue(index, value)
  if SPECIAL_OFFSETS[index] ~= nil then
    value = value + SPECIAL_OFFSETS[index]
  end
  self.data:setByte(self:getValueOffset(index), value)
end

function RolandJV1080Patch:getValue(index)  
  local value = self.data:getByte(self:getValueOffset(index))
  if SPECIAL_OFFSETS[index] ~= nil then
    value = value - SPECIAL_OFFSETS[index]
  end
  return value
end

function RolandJV1080Patch:toSyxMsg()
  local msg = Esq1SyxMsg(1, SINGLE_DATA_SIZE)
  local tmp = MemoryBlock(SINGLE_DATA_SIZE, true)
  tmp:copyFrom(self.data, self:getValueOffset(0), SINGLE_DATA_SIZE)
  msg:setPayload(tmp)
  return msg
end

function RolandJV1080Patch:getPatchData()
  local m = MemoryBlock(patchDataLeng, true)
  self.data:copyTo(m, 0, patchDataLeng)
  return m
end

function RolandJV1080Patch:getToneData(toneIndex)
  local m = MemoryBlock(toneDataLeng, true)
  self.data:copyTo(m, patchDataLeng + (toneIndex - 1) * toneDataLeng, toneDataLeng)
  return m
end