__DelkMsg = SyxMsg()

function Delk(programNumber, kgNumber)
	local pb = midiSrvc:splitBytes(programNumber)
	local bytes = {0xf0, 0x47, 0x00, 0x13, 0x48, pb[1], pb[2], kgNumber, 0xf7}
	return __DelkMsg:new{ data = bytes }
end
