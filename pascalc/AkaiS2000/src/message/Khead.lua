__KheadMsg = SyxMsg()

function __KheadMsg:getOffset()
	return self.offset
end

function __KheadMsg:getValueBlock()
	return self.valBlock
end

function Khead(prog, kg, headerOffset, valuesMemBlock)
	local pgm = midiSrvc:toNibbles(prog)
	local headerOffsArray = midiSrvc:splitBytes(headerOffset)
	local numBytesArray = midiSrvc:splitBytes(valuesMemBlock:getSize())

	local memBlock = MemoryBlock(13 + valuesMemBlock:getSize(), true)
	memBlock:loadFromHexString(string.format("F0 47 00 2A 48 %s %.2x %.2x %.2x %.2x %.2x%s F7",
		pgm:toHexString(1), kg, headerOffsArray[1], headerOffsArray[2], 
		numBytesArray[1], numBytesArray[2], valuesMemBlock:toHexString(1)))

	return __KheadMsg:new {
		data = memBlock,
		offset = headerOffset, 
		valBlock = valuesMemBlock 
	}
end
