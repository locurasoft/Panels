require("SyxMsg")
require("Logger")
require("mutils")

local PDATA_HEADER_SIZE = 7
local PDATA_SIZE = 292
local MAX_PROG_NBR = 127
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
    bytes = MemoryBlock(PDATA_SIZE, true)
    bytes:setByte(0, 0xF0)
    bytes:setByte(1, 0x47)
    bytes:setByte(3, 0x07)
    bytes:setByte(PDATA_SIZE - 1, 0xF7)

    self.data = bytes
    self[LUA_CONTRUCTOR_NAME] = "Pdata"
    self:storeNibbles("PTUNO", midiService:toTuneBlock(0))
    self:setName("EMPTYPROGRAM")
    self:storeNibbles("MODVLFOR", mutils.d2n(50))
    self:storeNibbles("MODVLVOL", mutils.d2n(50))
    self:storeNibbles("MODVLFOD", mutils.d2n(50))
    self:storeNibbles("MODVAMP1", mutils.d2n(50))
    self:storeNibbles("MODVAMP2", mutils.d2n(50))
    self:storeNibbles("MODVPAN1", mutils.d2n(50))
    self:storeNibbles("MODVPAN2", mutils.d2n(50))
    self:storeNibbles("MODVPAN3", mutils.d2n(50))
    self:storeNibbles("V_LOUD", mutils.d2n(50))
    self:storeNibbles("STEREO", mutils.d2n(50))
    self:storeNibbles("PANPOS", mutils.d2n(50))
    self:storeNibbles("TRANSPOSE", mutils.d2n(50))
    self:storeNibbles("POLYPH", mutils.d2n(15))
    self:storeNibbles("PRIORT", mutils.d2n(2))
    self:storeNibbles("P_PTCH", mutils.d2n(12))
  else
    assert(bytes:getByte(3) == 0x07, "Invalid pdata message")
    self.data = bytes
    self[LUA_CONTRUCTOR_NAME] = "Pdata"
  end
end

function PdataMsg:getOffset(blockIndex)
	return PDATA_HEADER_SIZE + blockIndex * 2
end

function PdataMsg:storeNibbles(blockId, valBlock)
	self.data:copyFrom(valBlock, self:getOffset(PROGRAM_BLOCK[blockId]), valBlock:getSize())
end

function PdataMsg:storePhead(phead)
	local valBlock = phead:getValueBlock()
	local offset = phead:getOffset()
	self.data:copyFrom(valBlock, self:getOffset(offset), valBlock:getSize())
end

function PdataMsg:getPdataValue(blockId)
	local offset = self:getOffset(PROGRAM_BLOCK[blockId])
	if blockId == "PTUNO" then
		return midiService:fromTuneBlock(self.data, offset)
	elseif blockId == "PRNAME" then
		return midiService:fromStringBlock(self.data, offset)
	else
		return midiService:fromDefaultBlock(self.data, offset)
	end
end

function PdataMsg:setName(programName)
	self:storeNibbles("PRNAME", midiService:toAkaiStringNibbles(programName))
end

function PdataMsg:getName()
	return midiService:fromStringBlock(self.data, self:getOffset(PROGRAM_BLOCK["PRNAME"]))
end

function PdataMsg:setNumKeyGroups(numKeyGroups)
	self:storeNibbles("GROUPS", mutils.d2n(numKeyGroups))
end

function PdataMsg:setMaxProgramNumber()
	self:setProgramNumber(MAX_PROG_NBR)
end

function PdataMsg:setProgramNumber(programNumber)
  if programNumber > MAX_PROG_NBR then
    programNumber = MAX_PROG_NBR
  elseif programNumber < 0 then
    programNumber = 0
  end
	self:storeNibbles("PRGNUM", mutils.d2n(programNumber))
end

function PdataMsg:getProgramNumber()
	return midiService:fromDefaultBlock(self.data, self:getOffset(PROGRAM_BLOCK["PRGNUM"]))
end

function PdataMsg:getData()
  return self.data
end

function PdataMsg:getNumKeyGroups()
  return self:getPdataValue("GROUPS")
end
