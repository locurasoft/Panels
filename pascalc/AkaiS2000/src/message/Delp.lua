__DelpMsg = SyxMsg()

function Delp(programNumber)
	local pb = midiSrvc:splitBytes(programNumber)
	local bytes = {0xf0, 0x47, 0x00, 0x12, 0x48, pb[1], pb[2], 0xf7}
	return __DelpMsg:new{ data = bytes }
end
