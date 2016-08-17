local numProgramsOffs = 5
local programNameOffs = 7

__PlistMsg = SyxMsg()

function __PlistMsg:getNumPrograms()
	return self.data:getByte(numProgramsOffs)
end

function __PlistMsg:getProgramNames()
	local offset = programNameOffs
	local numPrograms = self:getNumPrograms()
	local buf = MemoryBlock(PROGRAM_NAME_LENG, true)
	local programNames = {}

	while offset + PROGRAM_NAME_LENG < self.data:getSize() do
		self.data:copyTo(buf, offset, PROGRAM_NAME_LENG)
		offset = offset + PROGRAM_NAME_LENG
		local name = midiSrvc:fromAkaiString(buf)
		--console(string.format("Program Name: %s", name))
		table.insert(programNames, name)
	end
	return programNames
	
end	

function Plist(bytes)
	if bytes:getByte(3) == 0x03 then
		return __PlistMsg:new{ data = bytes }
	else
		console("MIDI is not a plist message")
		console(bytes:toHexString(1))
		return nil
	end
end
