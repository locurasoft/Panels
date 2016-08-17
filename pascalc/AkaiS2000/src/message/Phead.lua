__PheadMsg = SyxMsg()

function __PheadMsg:getOffset()
	return self.offset
end

function __PheadMsg:getValueBlock()
	return self.valBlock
end

function Phead(progNbr, headerOffset, valuesMemBlock)
	local pgm = midiSrvc:toNibbles(progNbr)
	local headerOffsArray = midiSrvc:splitBytes(headerOffset)
	local numBytesArray = midiSrvc:splitBytes(valuesMemBlock:getSize())

	local memBlock = MemoryBlock(13 + valuesMemBlock:getSize(), true)
	memBlock:loadFromHexString(string.format("F0 47 00 28 48 %s 0x00 %.2x %.2x %.2x %.2x%s F7",
		pgm:toHexString(1), headerOffsArray[1], headerOffsArray[2], 
		numBytesArray[1], numBytesArray[2], valuesMemBlock:toHexString(1)))

	return __PheadMsg:new {
		data = memBlock,
		offset = headerOffset, 
		valBlock = valuesMemBlock
	}
end
