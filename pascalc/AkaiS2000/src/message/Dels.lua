__DelsMsg = SyxMsg()

function Dels(sampleNumber)
	local sb = midiSrvc:splitBytes(sampleNumber)
	local bytes = {0xf0, 0x47, 0x00, 0x14, 0x48, sb[1], sb[2], 0xf7}
	return __DelsMsg:new{ data = bytes }
end
