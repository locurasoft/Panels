require("SyxMsg")

local KDATA_HEADER_SIZE = 9

local tuneBlocks = {
  ["VTUNO1"] = true,
  ["VTUNO2"] = true,
  ["VTUNO3"] = true,
  ["VTUNO4"] = true
}

local vssBlocks = {
  ["VSS1"] = true,
  ["VSS2"] = true,
  ["VSS3"] = true,
  ["VSS4"] = true
}

local defaultBytes = function()
  local bytes = MemoryBlock(393, true)
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
    self:storeNibbles("MODVFILT1", midiService:toNibbles(50))
    self:storeNibbles("MODVFILT2", midiService:toNibbles(50))
    self:storeNibbles("MODVFILT3", midiService:toNibbles(50))
    self:storeNibbles("K_FREQ", midiService:toNibbles(50))
    self:storeNibbles("MODVAMP3", midiService:toNibbles(50))
    self:storeNibbles("K_DAR1", midiService:toNibbles(50))
    self:storeNibbles("V_ATT1", midiService:toNibbles(50))
    self:storeNibbles("V_REL1", midiService:toNibbles(50))
    self:storeNibbles("V_ENV2", midiService:toNibbles(50))
    self:storeNibbles("K_DAR2", midiService:toNibbles(50))
    self:storeNibbles("V_ATT2", midiService:toNibbles(50))
    self:storeNibbles("V_REL2", midiService:toNibbles(50))
    self:storeNibbles("V_ENV2", midiService:toNibbles(50))
    self:storeNibbles("V_ENV2", midiService:toNibbles(50))
    self:storeNibbles("DECAY1", midiService:toNibbles(50))
    self:storeNibbles("SUSTN1", midiService:toNibbles(50))
    self:storeNibbles("ENV2R2", midiService:toNibbles(50))
    self:storeNibbles("ENV2R3", midiService:toNibbles(50))
    self:storeNibbles("ENV2L2", midiService:toNibbles(50))
    self:storeNibbles("ENV2L3", midiService:toNibbles(50))

    for i = 1,4 do
      self:storeNibbles(string.format("VFREQ%d", i), midiService:toNibbles(50))
      self:storeNibbles(string.format("VPANO%d", i), midiService:toNibbles(50))
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
	--log:info("setKdataValue %d (%d) -> %s", offset, kdataOffs, valBlock:toHexString(1))
	self.data:copyFrom(valBlock, kdataOffs, valBlock:getSize())
end

function KdataMsg:getKdataValue(blockId)
	local offset = self:getOffset(KEY_GROUP_BLOCK[blockId])
	if tuneBlocks[blockId] then
		log:info("getKdataValue %s => %d => %d", blockId, KEY_GROUP_BLOCK[blockId], offset)
		return midiService:fromTuneBlock(self.data, offset)
	elseif vssBlocks[blockId] then
		return midiService:fromVssBlock(self.data, offset)
	else
		return midiService:fromDefaultBlock(self.data, offset)
	end
end
