require("SyxMsg")
require("Logger")
require("mutils")

local PDATA_HEADER_SIZE = 4
local log = Logger("PdataMsg")

PdataMsg = {}
PdataMsg.__index = PdataMsg

setmetatable(PdataMsg, {
  __index = SyxMsg, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function PdataMsg:_init(bytes)
  SyxMsg._init(self)
  if bytes == nil then
    bytes = MemoryBlock(232, true)
    bytes:setByte(0, 0xF0)
    bytes:setByte(1, 0x47)
    bytes:setByte(3, 0x07)
    bytes:setByte(231, 0xF7)

    self.data = bytes
    self[LUA_CONTRUCTOR_NAME] = "Pdata"
    self:storeNibbles("PTUNO", midiSrvc:toTuneBlock(5000))
    self:setName("EMPTYPROGRAM")
    self:storeNibbles("MODVLFOR", mutils.toNibbles(50))
    self:storeNibbles("MODVLVOL", mutils.toNibbles(50))
    self:storeNibbles("MODVLFOD", mutils.toNibbles(50))
    self:storeNibbles("MODVAMP1", mutils.toNibbles(50))
    self:storeNibbles("MODVAMP2", mutils.toNibbles(50))
    self:storeNibbles("MODVPAN1", mutils.toNibbles(50))
    self:storeNibbles("MODVPAN2", mutils.toNibbles(50))
    self:storeNibbles("MODVPAN3", mutils.toNibbles(50))
    self:storeNibbles("V_LOUD", mutils.toNibbles(50))
    self:storeNibbles("STEREO", mutils.toNibbles(50))
    self:storeNibbles("PANPOS", mutils.toNibbles(50))
    self:storeNibbles("TRANSPOSE", mutils.toNibbles(50))
    self:storeNibbles("POLYPH", mutils.toNibbles(15))
    self:storeNibbles("PRIORT", mutils.toNibbles(2))
    self:storeNibbles("P_PTCH", mutils.toNibbles(12))
  elseif bytes:getByte(3) == 0x07 then
    self.data = bytes
    self[LUA_CONTRUCTOR_NAME] = "Pdata"
  end
end

function PdataMsg:getOffset(blockIndex)
	return PDATA_HEADER_SIZE + blockIndex * 2
end

function PdataMsg:storeNibbles(blockId, valBlock)
	self.data:copyFrom(valBlock, self:getOffset(programBlock[blockId]), valBlock:getSize())
end

function PdataMsg:storePhead(phead)
	local valBlock = phead:getValueBlock()
	local offset = phead:getOffset()
	--self.log:info("setPdataValue %s", valBlock:toHexString(1))
	self.data:copyFrom(valBlock, self:getOffset(offset), valBlock:getSize())
end

function PdataMsg:getPdataValue(blockId)
	local offset = self:getOffset(programBlock[blockId])
	if blockId == "PTUNO" then
		return midiSrvc:fromTuneBlock(self.data, offset)
	elseif blockId == "PRNAME" then
		return midiSrvc:fromStringBlock(self.data, offset)
	else
		return midiSrvc:fromDefaultBlock(self.data, offset)
	end
end

function PdataMsg:setName(programName)
	self:storeNibbles("PRNAME", midiSrvc:toAkaiString(programName))
end

function PdataMsg:getName()
	return midiSrvc:fromStringBlock(self.data, self:getOffset(programBlock["PRNAME"]))
end

function PdataMsg:setNumKeyGroups(numKeyGroups)
	self:storeNibbles("GROUPS", mutils.toNibbles(numKeyGroups))
end

function PdataMsg:setMaxProgramNumber()
	self:setProgramNumber(255)
end

function PdataMsg:setProgramNumber(programNumber)
	self:storeNibbles("PRGNUM", mutils.toNibbles(programNumber))
end

function PdataMsg:getProgramNumber()
	return midiSrvc:fromDefaultBlock(self.data, self:getOffset(programBlock["PRGNUM"]))
end

function PdataMsg:getData()
  return self.data
end
