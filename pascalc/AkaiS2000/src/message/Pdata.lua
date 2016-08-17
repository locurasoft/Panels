local PDATA_HEADER_SIZE = 4
local log = Logger("PdataMsg")

__PdataMsg = SyxMsg()

function __PdataMsg:getOffset(blockIndex)
	return PDATA_HEADER_SIZE + blockIndex * 2
end

function __PdataMsg:storeNibbles(blockId, valBlock)
	self.data:copyFrom(valBlock, self:getOffset(programBlock[blockId]), valBlock:getSize())
end

function __PdataMsg:storePhead(phead)
	local valBlock = phead:getValueBlock()
	local offset = phead:getOffset()
	--self.log:info("setPdataValue %s", valBlock:toHexString(1))
	self.data:copyFrom(valBlock, self:getOffset(offset), valBlock:getSize())
end

function __PdataMsg:getPdataValue(blockId)
	local offset = self:getOffset(programBlock[blockId])
	if blockId == "PTUNO" then
		return midiSrvc:fromTuneBlock(self.data, offset)
	elseif blockId == "PRNAME" then
		return midiSrvc:fromStringBlock(self.data, offset)
	else
		return midiSrvc:fromDefaultBlock(self.data, offset)
	end
end

function __PdataMsg:setName(programName)
	self:storeNibbles("PRNAME", midiSrvc:toAkaiString(programName))
end

function __PdataMsg:getName()
	return midiSrvc:fromStringBlock(self.data, self:getOffset(programBlock["PRNAME"]))
end

function __PdataMsg:setNumKeyGroups(numKeyGroups)
	self:storeNibbles("GROUPS", midiSrvc:toNibbles(numKeyGroups))
end

function __PdataMsg:setMaxProgramNumber()
	self:setProgramNumber(255)
end

function __PdataMsg:setProgramNumber(programNumber)
	self:storeNibbles("PRGNUM", midiSrvc:toNibbles(programNumber))
end

function __PdataMsg:getProgramNumber()
	return midiSrvc:fromDefaultBlock(self.data, self:getOffset(programBlock["PRGNUM"]))
end

function Pdata(bytes)
	if bytes == nil then
		bytes = MemoryBlock(232, true)
		bytes:setByte(0, 0xF0)
		bytes:setByte(1, 0x47)
		bytes:setByte(3, 0x07)
		bytes:setByte(231, 0xF7)

		local instance = __PdataMsg:new{ data = bytes, [LUA_CLASS_NAME] = "Pdata" }
		instance:storeNibbles("PTUNO", midiSrvc:toTuneBlock(5000))
		instance:setName("EMPTYPROGRAM")
		instance:storeNibbles("MODVLFOR", midiSrvc:toNibbles(50))
		instance:storeNibbles("MODVLVOL", midiSrvc:toNibbles(50))
		instance:storeNibbles("MODVLFOD", midiSrvc:toNibbles(50))
		instance:storeNibbles("MODVAMP1", midiSrvc:toNibbles(50))
		instance:storeNibbles("MODVAMP2", midiSrvc:toNibbles(50))
		instance:storeNibbles("MODVPAN1", midiSrvc:toNibbles(50))
		instance:storeNibbles("MODVPAN2", midiSrvc:toNibbles(50))
		instance:storeNibbles("MODVPAN3", midiSrvc:toNibbles(50))
		instance:storeNibbles("V_LOUD", midiSrvc:toNibbles(50))
		instance:storeNibbles("STEREO", midiSrvc:toNibbles(50))
		instance:storeNibbles("PANPOS", midiSrvc:toNibbles(50))
		instance:storeNibbles("TRANSPOSE", midiSrvc:toNibbles(50))
		instance:storeNibbles("POLYPH", midiSrvc:toNibbles(15))
		instance:storeNibbles("PRIORT", midiSrvc:toNibbles(2))
		instance:storeNibbles("P_PTCH", midiSrvc:toNibbles(12))
		return instance
	elseif bytes:getByte(3) == 0x07 then
		return __PdataMsg:new{ data = bytes, luaClassName = "Pdata" }
	else
		return nil
	end
end
