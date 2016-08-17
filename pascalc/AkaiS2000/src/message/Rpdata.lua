__RpdataMsg = SyxMsg()

function Rpdata(programNumber)
	local pb = midiSrvc:splitBytes(programNumber)
	local bytes = {0xf0, 0x47, 0x00, 0x06, 0x48, pb[1], pb[2], 0xf7}
	return __RpdataMsg:new{ data = bytes }
end
