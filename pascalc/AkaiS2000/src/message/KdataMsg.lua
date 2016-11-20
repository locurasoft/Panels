require("SyxMsg")

local KDATA_HEADER_SIZE = 8
local KDATA_SIZE = 393

local tuneBlocks = {
  ["VTUNO1"] = true,
  ["VTUNO2"] = true,
  ["VTUNO3"] = true,
  ["VTUNO4"] = true
}

local stringBlocks = {
  ["SNAME1"] = true,
  ["SNAME2"] = true,
  ["SNAME3"] = true,
  ["SNAME4"] = true
}

local vssBlocks = {
  ["VSS1"] = true,
  ["VSS2"] = true,
  ["VSS3"] = true,
  ["VSS4"] = true
}

local defaultBytes = function()
  local bytes = MemoryBlock(KDATA_SIZE, true)
  bytes:setByte(0, 0xF0)
  bytes:setByte(1, 0x47)
  bytes:setByte(3, 0x09)
  bytes:setByte(392, 0xF7)
  return bytes
end

local log = Logger("KdataMsg")

KdataMsg = {}
KdataMsg.__index = KdataMsg

setmetatable(KdataMsg, {
  __index = SyxMsg, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function KdataMsg:_init(bytes)
  SyxMsg._init(self)
  self[LUA_CONTRUCTOR_NAME] = "KdataMsg"

  if bytes == nil then
    self.data = defaultBytes()
    self:storeNibbles("MODVFILT1", mutils.d2n(50))
    self:storeNibbles("MODVFILT2", mutils.d2n(50))
    self:storeNibbles("MODVFILT3", mutils.d2n(50))
    self:storeNibbles("K_FREQ", mutils.d2n(50))
    self:storeNibbles("MODVAMP3", mutils.d2n(50))
    self:storeNibbles("K_DAR1", mutils.d2n(50))
    self:storeNibbles("V_ATT1", mutils.d2n(50))
    self:storeNibbles("V_REL1", mutils.d2n(50))
    self:storeNibbles("V_ENV2", mutils.d2n(50))
    self:storeNibbles("K_DAR2", mutils.d2n(50))
    self:storeNibbles("V_ATT2", mutils.d2n(50))
    self:storeNibbles("V_REL2", mutils.d2n(50))
    self:storeNibbles("V_ENV2", mutils.d2n(50))
    self:storeNibbles("V_ENV2", mutils.d2n(50))
    self:storeNibbles("DECAY1", mutils.d2n(50))
    self:storeNibbles("SUSTN1", mutils.d2n(50))
    self:storeNibbles("ENV2R2", mutils.d2n(50))
    self:storeNibbles("ENV2R3", mutils.d2n(50))
    self:storeNibbles("ENV2L2", mutils.d2n(50))
    self:storeNibbles("ENV2L3", mutils.d2n(50))

    for i = 1,4 do
      self:storeNibbles(string.format("VFREQ%d", i), mutils.d2n(50))
      self:storeNibbles(string.format("VPANO%d", i), mutils.d2n(50))
    end
  else
    assert(bytes:getByte(3) == 0x09, "Invalid Kdata message")
    self.data = bytes
  end

end

function KdataMsg:getOffset(blockIndex)
  return KDATA_HEADER_SIZE + blockIndex * 2
end

function KdataMsg:storeNibbles(blockId, valBlock)
  self.data:copyFrom(valBlock, self:getOffset(KEY_GROUP_BLOCK[blockId]), valBlock:getSize())
end

function KdataMsg:storeKhead(khead)
  local valBlock = khead:getValueBlock()
  local offset = khead:getOffset()
  local kdataOffs = self:getOffset(offset)
  self.data:copyFrom(valBlock, kdataOffs, valBlock:getSize())
end

function KdataMsg:getKdataValue(blockId)
  local offset = self:getOffset(KEY_GROUP_BLOCK[blockId])
  if tuneBlocks[blockId] then
    return midiService:fromTuneBlock(self.data, offset)
  elseif stringBlocks[blockId] then
    return midiService:fromStringBlock(self.data, offset)
  elseif vssBlocks[blockId] then
    return midiService:fromVssBlock(self.data, offset)
  else
    return midiService:fromDefaultBlock(self.data, offset)
  end
end

function KdataMsg:getProgramNumber()
  return midiService:fromDefaultBlock(self.data, 5)
end

function KdataMsg:getKeygroupNumber()
  return self.data:getByte(7)
end